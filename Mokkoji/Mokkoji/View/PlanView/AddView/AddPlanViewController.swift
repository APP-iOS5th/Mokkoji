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
    
    var saveButton: UIBarButtonItem?
    
    var mapInfoList: [MapInfo] = [] {
        didSet {
            /// 배열의 크기를 mapInfoList의 크기와 동일하게 설정하고 nil로 초기화
            /// mapInfoList가 변경될 때 selectedTimes 크기 조정
            selectedTimes = Array(repeating: nil, count: mapInfoList.count)
            /// mapInfoList가 변경될 때 detailTexts 크기 조정
            detailTexts = Array(repeating: "", count: mapInfoList.count)
            
        }
    }
    var selectedTimes: [Date?]?
    var detailTexts: [String]?
    var participants: [User]?
    
    lazy var mainContainer: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    lazy var titleText: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.placeholder = "약속 제목을 입력하세요."
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    lazy var bodyText: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.placeholder = "약속 내용을 간단히 입력하세요."
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    lazy var dateField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.placeholder = "약속 날짜를 선택하세요."
        textField.inputView = datePicker
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
    
    lazy var friendList: UILabel = {
        let textLabel = UILabel()
        textLabel.numberOfLines = 0 /// 여러 줄 표시
        textLabel.lineBreakMode = .byWordWrapping /// 단어 단위로 줄바꿈
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        return textLabel
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
    
    lazy var mapView: UIView = {
        let view = UIView()
        addChild(mapViewController)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(PlaceListTableViewCell.self, forCellReuseIdentifier: "placeCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    /// tableView의 동적 높이 설정
    var tableViewHeightConstraint: NSLayoutConstraint?
    
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
        /// 사용자 입력 방지
        dateField.delegate = self
        
        /// tableView 행 삭제를 위한 gesture 설정
        let deleteLongPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        tableView.addGestureRecognizer(deleteLongPressRecognizer)
        
        /// 터치 이벤트를 감지하여 UIDatePicker를 숨기기 위한 gesture 설정
        let hideDatePickerTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.view.addGestureRecognizer(hideDatePickerTapGesture)
        
        mapView.addSubview(mapViewController.view)
        
        self.view.addSubview(mainContainer)
        
        mainContainer.addSubview(titleText)
        mainContainer.addSubview(bodyText)
        mainContainer.addSubview(dateField)
        mainContainer.addSubview(friendList)
        mainContainer.addSubview(inviteButton)
        mainContainer.addSubview(addMapButton)
        mainContainer.addSubview(mapView)
        mainContainer.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            mainContainer.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 20),
            mainContainer.bottomAnchor.constraint(equalTo: self.view.keyboardLayoutGuide.topAnchor, constant: -20),
            mainContainer.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            mainContainer.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            
            /// ScrollView에 맞춰 제약조건 설정
            titleText.topAnchor.constraint(equalTo: mainContainer.contentLayoutGuide.topAnchor),
            titleText.leadingAnchor.constraint(equalTo: mainContainer.frameLayoutGuide.leadingAnchor),
            titleText.trailingAnchor.constraint(equalTo: mainContainer.frameLayoutGuide.trailingAnchor),
            
            bodyText.topAnchor.constraint(equalTo: titleText.bottomAnchor, constant: 5),
            bodyText.leadingAnchor.constraint(equalTo: mainContainer.frameLayoutGuide.leadingAnchor),
            bodyText.trailingAnchor.constraint(equalTo: mainContainer.frameLayoutGuide.trailingAnchor),
            
            dateField.topAnchor.constraint(equalTo: bodyText.bottomAnchor, constant: 5),
            dateField.leadingAnchor.constraint(equalTo: mainContainer.frameLayoutGuide.leadingAnchor),
            dateField.trailingAnchor.constraint(equalTo: mainContainer.frameLayoutGuide.trailingAnchor),
            
            friendList.topAnchor.constraint(equalTo: dateField.bottomAnchor, constant: 15),
            friendList.leadingAnchor.constraint(equalTo: mainContainer.frameLayoutGuide.leadingAnchor),
            friendList.trailingAnchor.constraint(equalTo: mainContainer.frameLayoutGuide.trailingAnchor),
            
            inviteButton.topAnchor.constraint(equalTo: friendList.bottomAnchor, constant: 15),
            inviteButton.leadingAnchor.constraint(equalTo: mainContainer.frameLayoutGuide.leadingAnchor),
            inviteButton.widthAnchor.constraint(equalToConstant: 80),

            addMapButton.topAnchor.constraint(equalTo: inviteButton.bottomAnchor, constant: 15),
            addMapButton.leadingAnchor.constraint(equalTo: mainContainer.frameLayoutGuide.leadingAnchor),
            addMapButton.trailingAnchor.constraint(equalTo: mainContainer.frameLayoutGuide.trailingAnchor),
            
            mapView.topAnchor.constraint(equalTo: addMapButton.bottomAnchor, constant: 15),
            mapView.leadingAnchor.constraint(equalTo: mainContainer.frameLayoutGuide.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: mainContainer.frameLayoutGuide.trailingAnchor),
            mapView.widthAnchor.constraint(equalToConstant: 300),
            mapView.heightAnchor.constraint(equalToConstant: 300),
            
            tableView.topAnchor.constraint(equalTo: mapView.bottomAnchor, constant: 15),
            tableView.bottomAnchor.constraint(equalTo: mainContainer.contentLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: mainContainer.frameLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: mainContainer.frameLayoutGuide.trailingAnchor),
        ])
        
        /// tableView의 동적 높이 설정
        tableViewHeightConstraint = tableView.heightAnchor.constraint(equalToConstant: 0)
        tableViewHeightConstraint?.isActive = true
        
        /// tableVIew의 contentSize 관찰 시작
        tableView.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        tableViewHeightConstraint?.constant = tableView.contentSize.height
        
        mapViewController.didMove(toParent: self)
        
    }
        
    /// tableView의 동적 높이 설정을 위한 옵저버 설정 - tableVIew의 contentSize 관찰
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "contentSize", let tableView = object as? UITableView {
            tableViewHeightConstraint?.constant = tableView.contentSize.height
        }
    }

    deinit {
        tableView.removeObserver(self, forKeyPath: "contentSize")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
        mapViewController.mapController?.activateEngine()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        /// 선택한 장소를 삭제했을 때 부모 뷰와 자식 뷰의 장소 리스트가 같도록 설정
        /// 선택한 장소 반영 전에 이전 버튼 눌렀을 때 부모 뷰와 자식 뷰의 장소 리스트가 같도록 설정
        self.mapViewController.selectedPlaces = self.mapInfoList
        
        /// 부모 뷰 컨트롤러가 사라질 때 엔진 일시 중지
//        mapViewController.mapController?.pauseEngine()
    }
  
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        /// 부모 뷰 컨트롤러가 사라질 때 엔진 정지
//        mapViewController.mapController?.resetEngine()
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
        
        // TODO: - 뷰가 다시 로드될 때 timePicker와 detailTextField가 초기화되는 묹
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
        
        // TODO: - 제약조건 설정 안되는 문제 해결
        /// 초대된 친구 추가 후 제약조건 수정
        if ((self.friendList.text?.isEmpty) == nil) {
            /// friendList 제약조건 비활성화
            NSLayoutConstraint.deactivate([
                friendList.topAnchor.constraint(equalTo: dateField.bottomAnchor),
                friendList.leadingAnchor.constraint(equalTo: mainContainer.frameLayoutGuide.leadingAnchor),
                friendList.trailingAnchor.constraint(equalTo: mainContainer.frameLayoutGuide.trailingAnchor)
            ])
            /// friendList 제약조건 다시 활성화
            NSLayoutConstraint.activate([
                friendList.topAnchor.constraint(equalTo: dateField.bottomAnchor, constant: 15),
                friendList.leadingAnchor.constraint(equalTo: mainContainer.frameLayoutGuide.leadingAnchor),
                friendList.trailingAnchor.constraint(equalTo: mainContainer.frameLayoutGuide.trailingAnchor),
            ])
        }
    }
    
    // MARK: - UITextFieldDelegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return false /// dateField 사용자 입력을 허용하지 않음
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
            self.saveUserToFirestore(user: user, userId: String(user.id))
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
    func saveUserToFirestore(user: User, userId: String) {
        let userRef = db.collection("users").document(userId)
        do {
            try userRef.setData(from: user)
            print("Plan data saved")
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
