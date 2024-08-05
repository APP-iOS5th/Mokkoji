//
//  AddPlanViewController.swift
//  Mokkoji
//
//  Created by 박지혜 on 6/11/24.
//

import UIKit
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import KakaoMapsSDK

class AddPlanViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, SelectedPlaceListDelegate, SelectDoneFriendListDelegate, UITextFieldDelegate {
    
    let db = Firestore.firestore()
    let inviteFriendTableViewController = InviteFriendTableViewController()
    let mapViewController = MapViewController()
    var previewMapViewController = PreviewMapViewController(selectedPlaces: [])
    
    var saveButton: UIBarButtonItem?
    
    /// tableView의 동적 높이 설정
    var tableViewHeightConstraint: NSLayoutConstraint?
    
    var mapInfoList: [MapInfo] = [] {
        didSet {
            /// 배열의 크기를 mapInfoList의 크기와 동일하게 설정하고 nil로 초기화
            /// mapInfoList가 변경될 때 selectedTimes 크기 조정
            selectedTimes = Array(repeating: nil, count: mapInfoList.count)
            /// mapInfoList가 변경될 때 detailTexts 크기 조정
            detailTexts = Array(repeating: "", count: mapInfoList.count)
            
            /// previewMapViewController의 selectedPlaces를 mapInfoList로 변경
            previewMapViewController.selectedPlaces = mapInfoList
            
        }
    }
    var selectedTimes: [Date?]?
    var detailTexts: [String]?
    var participants: [User]?
    
    var selectedTextField: UITextField?
    
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var titleText: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.placeholder = "약속 제목을 입력하세요."
        textField.delegate = self
        textField.translatesAutoresizingMaskIntoConstraints = false
        becomeFirstResponder()
        return textField
    }()
    
    lazy var bodyText: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.placeholder = "약속 내용을 간단히 입력하세요."
        textField.delegate = self
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    lazy var dateField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.placeholder = "약속 날짜를 선택하세요."
        textField.inputView = datePicker
        /// 사용자 입력 방지
        textField.delegate = self
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.preferredDatePickerStyle = .inline
        datePicker.datePickerMode = .date
        datePicker.backgroundColor = .systemGray6
        datePicker.minimumDate = Date() /// 오늘부터 선택 가능
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        
        datePicker.addAction(UIAction { [weak self] _ in
            self?.dateChanged()
        }, for: .valueChanged)
        return datePicker
    }()
    
    lazy var friendList: UITextField = {
        let textField = UITextField()
        textField.isEnabled = false
        textField.borderStyle = .roundedRect
        textField.placeholder = "초대할 친구를 추가하세요."
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    lazy var inviteButton: UIButton = {
        let button = UIButton()
        button.setTitle("친구 초대", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .black
        button.layer.cornerRadius = 7
        button.addAction(UIAction { [weak self] _ in
            self?.inviteButtonTapped()
        }, for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var addMapButton: UIButton = {
        let button = UIButton()
        button.setTitle("장소 추가", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(named: "Primary_Color")
        button.layer.cornerRadius = 7
        button.addAction(UIAction { [weak self] _ in
            self?.addMapButtonTapped()
        }, for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(PlaceListTableViewCell.self, forCellReuseIdentifier: "placeCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    // MARK: - deinit
    deinit {
        tableView.removeObserver(self, forKeyPath: "contentSize")
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        
        /// Title 및 BarButton 설정
        self.navigationItem.title = "약속 추가"
        saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveButtonTapped))
        self.navigationItem.rightBarButtonItem = saveButton
        /// 값이 다 채워지기 전까지 save 버튼 비활성화
        saveButton?.isEnabled = false
        
        self.navigationController?.navigationBar.prefersLargeTitles = false
        self.navigationItem.largeTitleDisplayMode = .automatic
        
        inviteFriendTableViewController.delegate = self
        mapViewController.delegate = self
        
        self.view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(titleText)
        contentView.addSubview(bodyText)
        contentView.addSubview(dateField)
        contentView.addSubview(friendList)
        contentView.addSubview(inviteButton)
        contentView.addSubview(addMapButton)
        contentView.addSubview(tableView)
        contentView.addSubview(previewMapViewController.view)
        
        /// 자식뷰 설정
        addChild(previewMapViewController)
        previewMapViewController.didMove(toParent: self)
        previewMapViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            titleText.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            titleText.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleText.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            titleText.heightAnchor.constraint(equalToConstant: 40),
            
            bodyText.topAnchor.constraint(equalTo: titleText.bottomAnchor, constant: 5),
            bodyText.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            bodyText.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            bodyText.heightAnchor.constraint(equalToConstant: 40),
            
            dateField.topAnchor.constraint(equalTo: bodyText.bottomAnchor, constant: 5),
            dateField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            dateField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            dateField.heightAnchor.constraint(equalToConstant: 40),
            
            friendList.topAnchor.constraint(equalTo: dateField.bottomAnchor, constant: 5),
            friendList.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            friendList.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            friendList.widthAnchor.constraint(equalTo: dateField.widthAnchor),
            friendList.heightAnchor.constraint(equalToConstant: 40),
            
            inviteButton.topAnchor.constraint(equalTo: friendList.bottomAnchor, constant: 5),
            inviteButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            inviteButton.widthAnchor.constraint(equalToConstant: 80),
            inviteButton.heightAnchor.constraint(equalToConstant: 40),

            addMapButton.topAnchor.constraint(equalTo: inviteButton.bottomAnchor, constant: 15),
            addMapButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            addMapButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            addMapButton.heightAnchor.constraint(equalToConstant: 40),
            
            tableView.topAnchor.constraint(equalTo: addMapButton.bottomAnchor, constant: 15),
            tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            previewMapViewController.view.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 15),
            previewMapViewController.view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            previewMapViewController.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            previewMapViewController.view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            previewMapViewController.view.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.9),
            previewMapViewController.view.heightAnchor.constraint(equalTo: previewMapViewController.view.widthAnchor, multiplier: 2)
        ])
        
        /// tableView의 동적 높이 설정
        tableViewHeightConstraint = tableView.heightAnchor.constraint(equalToConstant: 0)
        tableViewHeightConstraint?.isActive = true
        
        /// tableVIew의 contentSize 관찰 시작
        tableView.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        tableViewHeightConstraint?.constant = tableView.contentSize.height
        
        /// 키보드 핸들링 옵저버 추가
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        /// tableView 행 삭제를 위한 gesture 설정
        let deleteLongPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        tableView.addGestureRecognizer(deleteLongPressRecognizer)
        
        /// 터치 이벤트를 감지하여 UIDatePicker를 숨기기 위한 gesture 설정
        let hideDatePickerTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.view.addGestureRecognizer(hideDatePickerTapGesture)
        
        /// 터치 이벤트를 감지하여 keyboard를 숨기기 위한 gesture 설정
        let hideKeyboardTapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(hideKeyboardTapGesture)
    }
        
    /// tableView의 동적 높이 설정을 위한 옵저버 설정 - tableVIew의 contentSize 관찰
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "contentSize", let tableView = object as? UITableView {
            tableViewHeightConstraint?.constant = tableView.contentSize.height
        }
    }
    
    /// 키보드 내리기
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            view.endEditing(true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        /// 선택한 장소를 삭제했을 때 부모 뷰와 자식 뷰의 장소 리스트가 같도록 설정
        /// 선택한 장소 반영 전에 이전 버튼 눌렀을 때 부모 뷰와 자식 뷰의 장소 리스트가 같도록 설정
        self.mapViewController.selectedPlaces = self.mapInfoList
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mapInfoList.count
        
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        /// 커스텀 셀을 생성하여 장소 리스트에 재사용
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "placeCell", for: indexPath) as? PlaceListTableViewCell else {
            return UITableViewCell()
        }
        
        /// tableView 데이터 출력 형태 지정
        let placeOrder = "\(indexPath.row + 1).circle.fill"
        let numbering = UIImage(systemName: placeOrder)
        let placeName = "\(mapInfoList[indexPath.row].placeName)"
        cell.configure(number: numbering, placeInfo: placeName)
        
        // TODO: - 뷰가 다시 로드될 때 timePicker와 detailTextField가 초기화되는 문제
        /// UIDatePicker의 tag를 설정
        cell.timePicker.tag = indexPath.row
        cell.timePicker.addTarget(self, action: #selector(timeChanged(_:)), for: .valueChanged)

        /// 저장된 시간으로 UIDatePicker 설정
        if let selectedTime = selectedTimes?[indexPath.row] {
            cell.timePicker.date = selectedTime
        } else {
            /// 저장된 시간이 없을 경우, 기본 시간을 00:00으로 설정
            cell.getDefaultDate()
        }
        
        /// UITextField의 tag를 설정
        cell.detailTextField.tag = indexPath.row
        
        /// 텍스트 필드가 편집될 때와 리턴 키를 눌렀을 때
        cell.detailTextField.addTarget(self, action: #selector(detailTextChanged(_:)), for: .editingChanged)
        cell.detailTextField.addTarget(self, action: #selector(detailTextChanged(_:)), for: .editingDidEndOnExit)

        /// 저장된 텍스트로 UITextField 설정
        let detailText = detailTexts?[indexPath.row]
        cell.detailTextField.text = detailText
        
        cell.detailTextField.delegate = self
        
        return cell
    }
    
    // MARK: - SelectedPlaceListDelegate
    func didAppendPlace(places: [MapInfo]) {
        self.mapInfoList = places
        tableView.reloadData()
    }
    
    // MARK: - SelectDoneFriendListDelegate
    func didInviteFriends(friends: [User]) {
        self.participants = friends
        
        /// 리스트의 요소들을 하나의 문자열로 합치기
        var names: [String] = []
        for friend in friends {
            names.append(friend.name)
        }
        let combinedString = names.joined(separator: ", ")
        self.friendList.text = combinedString
        self.friendList.textColor = .black
    }
    
    // MARK: - UITextFieldDelegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == dateField {
            return false /// dateField 사용자 입력을 허용하지 않음
        } else {
            return true
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        selectedTextField = textField
        /// textField가 터치되면 FirstResponder로 설정되어야 키보드 이벤트가 발생함
        textField.becomeFirstResponder()
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        selectedTextField = nil
    }

    // MARK: - Keyboard Handling Methods
    /// 리턴 버튼을 누르면 키보드가 내려가는 함수
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    /// 텍스트 필드 이외의 부분을 누르면 키보드가 내려가는 함수
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }

    /// 키보드가 나타날 때 호출되는 함수
    @objc func keyboardWillShow(_ notification: NSNotification) {
        print("Keyboard will show")
        
        /// dateField가 첫 번째 응답자인 경우 건너뜀
        guard dateField.isFirstResponder == false else { return }
        
        if let userInfo = notification.userInfo,
           let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            
            let keyboardHeight = keyboardFrame.height
            
            /// 현재 선택된 textField가 키보드에 가려지지 않도록 스크롤
            if let activeField = selectedTextField {
                let activeFieldFrame = activeField.convert(activeField.bounds, to: self.view)
                let activeFieldBottomY = activeFieldFrame.maxY
                let keyboardOriginY = self.view.frame.height - keyboardHeight
                
                /// 키보드의 상단과 텍스트 필드의 하단이 맞닿도록 스크롤
                if activeFieldBottomY > keyboardOriginY {
                    let offset = activeFieldBottomY - keyboardOriginY + 10
                    tableView.setContentOffset(CGPoint(x: 0, y: tableView.contentOffset.y + offset), animated: true)
                }
            }
        }
    }
        
    /// 키보드가 사라질 때 호출되는 함수
    @objc func keyboardWillHide(_ notification: NSNotification) {
        print("Keyboard will hide")
        let contentInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }
    
    // MARK: - Methods
    @objc func saveButtonTapped() {
        /// Plan 객체 생성
        guard let newPlans = makePlan() else {
            return
        }
        
        /// User 정보 불러오기
        guard var user = UserInfo.shared.user else {
            return
        }
        
        /// User에 Plan 추가
        user.plan = newPlans
        
        /// User의 plan 데이터 firestore에 저장
        DispatchQueue.main.async {
            self.saveUserToFirestore(user: user, userEmail: user.email)
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func handleLongPress(gestureRecognizer: UILongPressGestureRecognizer) {
        /// tableView의 행을 꾹 눌렀을 때 이벤트 발생
        if gestureRecognizer.state == .began {
            let point = gestureRecognizer.location(in: tableView)
            if let indexPath = tableView.indexPathForRow(at: point) {
                /// AlertController를 사용하여 삭제 확인
                let alertController = UIAlertController(title: nil, message: "이 항목을 삭제하시겠습니까?", preferredStyle: .actionSheet)
                let deleteAction = UIAlertAction(title: "삭제", style: .destructive) { [weak self] _ in
                    /// 데이터 삭제
                    self?.mapInfoList.remove(at: indexPath.row)
                    /// 테이블 뷰에서 행 삭제
                    self?.tableView.deleteRows(at: [indexPath], with: .automatic)
                    self?.tableView.reloadData()
                }
                alertController.addAction(deleteAction)
                
                /// 삭제 취소
                let cancelAction = UIAlertAction(title: "취소", style: .cancel)
                alertController.addAction(cancelAction)
                
                present(alertController, animated: true, completion: nil)
            } 
        }
    }
    
    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
        /// 터치된 위치를 확인하여 터치된 뷰가 dateTextField 또는 그 하위 뷰이면 리턴
        let touchLocation = gesture.location(in: view)
        if dateField.frame.contains(touchLocation) {
            return
        }
        
        /// dateTextField 이외의 영역을 터치했을 때 UIDatePicker를 숨김
        dateField.resignFirstResponder()
    }
    
    /// 각 장소에서 선택된 시간
    @objc func timeChanged(_ sender: UIDatePicker) {
        let index = sender.tag
        
        /// 사용자가 선택한 시간을 그대로 Date로 저장
        let selectedTime = sender.date
            
        selectedTimes?[index] = selectedTime
        
        updateSaveButtonState()
    }
    
    /// 각 장소에 입력한 상세내용
    @objc func detailTextChanged(_ sender: UITextField) {
        let index = sender.tag
        
        /// 사용자가 작성한 상세내용을 그대로 String으로 저장
        let detailText = sender.text
            
        detailTexts?[index] = detailText ?? ""
        
        updateSaveButtonState()
    }
    
    /// Firestore에 데이터 저장
    func saveUserToFirestore(user: User, userEmail: String) {
        let userRef = db.collection("users").document(userEmail)
        do {
            try userRef.setData(from: user)
        } catch let error {
            print("Firestore Writing Error: \(error)")
        }
    }
    
    /// Plan 객체 생성
    func makePlan() -> [Plan]? {
        
        /// plan에 필요한 프로퍼티
        guard let title = titleText.text, !title.isEmpty else {
            return nil
        }
        
        guard let body = bodyText.text, !body.isEmpty else {
            return nil
        }
        
        guard let date = dateField.text, !date.isEmpty else {
            return nil
        }
        
        guard let user = UserInfo.shared.user else {
            return nil
        }
        
        var newPlans = [Plan]()
        
        /// User가 이미 plan을 가지고 있을 때
        if let currentPlan = user.plan {
            newPlans = currentPlan
        }
        
        let newPlan = Plan(uuid: UUID(), title: title, body: body, date: date, mapTimeInfo: selectedTimes ?? [], detailTextInfo: detailTexts ?? [], mapInfo: mapInfoList, participant: participants)
        newPlans.append(newPlan)
        
        return newPlans
    }
    
    /// datePicker에서 선택한 날짜 formatting
    func dateChanged() {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.dateStyle = .medium
        dateFormatter.dateFormat = "yyyy년 MM월 dd일"
        let selectedDate = dateFormatter.string(from: datePicker.date)
        
        dateField.text = selectedDate
        dateField.resignFirstResponder()
    }
    
    /// 친구 초대 버튼 눌렀을 때
    func inviteButtonTapped() {
        let navigationController = UINavigationController(rootViewController: inviteFriendTableViewController)
        present(navigationController, animated: true)
    }
    
    /// 지도 추가 버튼 눌렀을 때
    func addMapButtonTapped() {
        self.navigationController?.pushViewController(mapViewController, animated: true)
    }
    
    func updateSaveButtonState() {
        let allTimesSelected = !(selectedTimes?.contains(where: { $0 == nil }))!
        let allDetailsEntered = !detailTexts!.contains(where: { $0.isEmpty })
        
        saveButton?.isEnabled = allTimesSelected && allDetailsEntered
    }
}
