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

extension UIImageView {
    /// 이미지 로딩 후 completion 클로저 실행
    func loadImage(from url: URL, completion: ((UIImage?) -> Void)? = nil) {
        /// URLSession을 사용한 비동기적 이미지 다운로드
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil, let downloadedImage = UIImage(data: data) else {
                DispatchQueue.main.async {
                    completion?(nil)
                }
                return
            }
            DispatchQueue.main.async {
                self.image = downloadedImage
                completion?(downloadedImage)
            }
        }
        task.resume()
    }
}

class AddPlanViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, SelectedPlaceListDelegate {
    let db = Firestore.firestore()
    let mapViewController = MapViewController()
    
    var selectedTimes: [Date] = []
    var mapInfoList: [MapInfo] = []
    var planList: [Plan] = []
    
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
        textField.placeholder = "약속 날짜를 입력하세요."
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
    
    lazy var profileImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person.circle.fill") /// 임시 이미지
        imageView.tintColor = .gray
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    lazy var inviteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("친구 초대", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(named: "Primary_Color")
        button.layer.cornerRadius = 7
        button.addAction(UIAction { [weak self] _ in
            self?.inviteButtonTapped()
        }, for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var spacerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
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
        tableView.register(PlaceListTableViewCell.self, forCellReuseIdentifier: "placeListCell")
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
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveButtonTapped))
        self.navigationController?.navigationBar.prefersLargeTitles = false
        self.navigationItem.largeTitleDisplayMode = .always
        mapViewController.delegate = self
        
        /// tableView 행 삭제를 위한 gesture 설정
        let deleteLongPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        tableView.addGestureRecognizer(deleteLongPressRecognizer)
        
        mapView.addSubview(mapViewController.view)
        
        stackView.addArrangedSubview(profileImage)
        stackView.addArrangedSubview(inviteButton)
        stackView.addArrangedSubview(spacerView)
        
        self.view.addSubview(mainContainer)
        
        mainContainer.addSubview(titleText)
        mainContainer.addSubview(bodyText)
        mainContainer.addSubview(dateField)
        mainContainer.addSubview(stackView)
        mainContainer.addSubview(addMapButton)
        mainContainer.addSubview(mapView)
        mainContainer.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            mainContainer.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 20),
            mainContainer.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
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
            
            profileImage.topAnchor.constraint(equalTo: stackView.topAnchor, constant: 5),
            profileImage.widthAnchor.constraint(equalToConstant: 50),
            profileImage.heightAnchor.constraint(equalToConstant: 50),
            
            inviteButton.topAnchor.constraint(equalTo: stackView.topAnchor, constant: 5),
            inviteButton.leadingAnchor.constraint(equalTo: profileImage.trailingAnchor),
            inviteButton.widthAnchor.constraint(equalToConstant: 70),
            inviteButton.heightAnchor.constraint(equalToConstant: 30),
            
            stackView.topAnchor.constraint(equalTo: dateField.bottomAnchor, constant: 15),
            stackView.leadingAnchor.constraint(equalTo: mainContainer.frameLayoutGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: mainContainer.frameLayoutGuide.trailingAnchor),
            
            addMapButton.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 15),
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
        
        // TODO: - 친구 초대를 통해 선택된 user의 profileUrl을 전달받아 이미지를 그림
//        let user =
//        profileImage.loadImage(from: user.profileImageUrl) { [weak self] image in
//            if let image = image {
//                print("Success image loading")
//            } else {
//                print("Fail image loading")
//                self.profileImage.image = UIImage(systemName: "person.circle.fill")
//            }
//        }
        
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
//        /// PlanListView의 title은 inline으로 유지
//        self.navigationController?.navigationBar.prefersLargeTitles = false
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "placeListCell", for: indexPath) as? PlaceListTableViewCell else {
            return UITableViewCell()
        }
        
        /// tableView 데이터 출력 형태 지정
        let placeOrder = "\(indexPath.row + 1).circle.fill"
        let numbering = UIImage(systemName: placeOrder)
        let placeName = "\(mapInfoList[indexPath.row].placeName)"
        cell.configure(number: numbering, placeInfo: placeName)
        
        /// 선택된 각 장소의 시간 저장
        if let selectedTime = cell.selectedTime {
            selectedTimes.append(selectedTime)
        }

        return cell
    }
    
    // MARK: - SelectedPlaceListDelegate
    func didAppendPlace(places: [MapInfo]) {
        self.mapInfoList = places
        tableView.reloadData()
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
        
        let newPlan = Plan(uuid: UUID(), title: title, body: body, date: date, mapTimeInfo: selectedTimes, mapInfo: mapInfoList)
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
        let inviteFriendTableViewController = InviteFriendTableViewController()
        let navigationController = UINavigationController(rootViewController: inviteFriendTableViewController)
        present(navigationController, animated: true)
    }
    
    /// 지도 추가 버튼 눌렀을 때
    func addMapButtonTapped() {
        self.navigationController?.pushViewController(mapViewController, animated: true)
    }
}
