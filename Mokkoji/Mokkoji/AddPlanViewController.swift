//
//  AddPlanViewController.swift
//  Mokkoji
//
//  Created by 박지혜 on 6/11/24.
//

import UIKit

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
    
    let mapViewController = MapViewController()
    var mapInfoList: [MapInfo] = []
    
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
        imageView.tintColor = .black
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    lazy var inviteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("친구 초대", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
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
        button.backgroundColor = .black
        button.layer.cornerRadius = 7
        button.addAction(UIAction { [weak self] _ in
            self?.addMapButtonTapped()
        }, for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var mapView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "map")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        self.navigationItem.title = "약속 추가"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveButtonTapped))
        
        mapViewController.delegate = self
        
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
            
            titleText.topAnchor.constraint(equalTo: mainContainer.contentLayoutGuide.topAnchor),
            titleText.leadingAnchor.constraint(equalTo: mainContainer.contentLayoutGuide.leadingAnchor),
            titleText.trailingAnchor.constraint(equalTo: mainContainer.contentLayoutGuide.trailingAnchor),
        
            bodyText.topAnchor.constraint(equalTo: titleText.bottomAnchor, constant: 5),
            bodyText.leadingAnchor.constraint(equalTo: mainContainer.contentLayoutGuide.leadingAnchor),
            bodyText.trailingAnchor.constraint(equalTo: mainContainer.contentLayoutGuide.trailingAnchor),
            
            dateField.topAnchor.constraint(equalTo: bodyText.bottomAnchor, constant: 5),
            dateField.leadingAnchor.constraint(equalTo: mainContainer.contentLayoutGuide.leadingAnchor),
            dateField.trailingAnchor.constraint(equalTo: mainContainer.contentLayoutGuide.trailingAnchor),
            
            profileImage.topAnchor.constraint(equalTo: stackView.topAnchor, constant: 5),
            profileImage.widthAnchor.constraint(equalToConstant: 50),
            profileImage.heightAnchor.constraint(equalToConstant: 50),
            
            inviteButton.topAnchor.constraint(equalTo: stackView.topAnchor, constant: 5),
            inviteButton.leadingAnchor.constraint(equalTo: profileImage.trailingAnchor),
            inviteButton.widthAnchor.constraint(equalToConstant: 70),
            inviteButton.heightAnchor.constraint(equalToConstant: 30),
            
            stackView.topAnchor.constraint(equalTo: dateField.bottomAnchor, constant: 15),
            stackView.leadingAnchor.constraint(equalTo: mainContainer.contentLayoutGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: mainContainer.contentLayoutGuide.trailingAnchor),
            
            addMapButton.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 15),
            addMapButton.leadingAnchor.constraint(equalTo: mainContainer.contentLayoutGuide.leadingAnchor),
            addMapButton.trailingAnchor.constraint(equalTo: mainContainer.contentLayoutGuide.trailingAnchor),
            
            mapView.topAnchor.constraint(equalTo: addMapButton.bottomAnchor, constant: 15),
            mapView.leadingAnchor.constraint(equalTo: mainContainer.contentLayoutGuide.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: mainContainer.contentLayoutGuide.trailingAnchor),
            mapView.heightAnchor.constraint(equalToConstant: 300),
            
            tableView.topAnchor.constraint(equalTo: mapView.bottomAnchor, constant: 15),
//            tableView.bottomAnchor.constraint(equalTo: mainContainer.contentLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: mainContainer.contentLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: mainContainer.contentLayoutGuide.trailingAnchor)
        ])
        
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        /// 큰 타이틀 설정
        self.navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        /// PlanListView의 title은 inline으로 유지
        self.navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mapInfoList.count
        
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // TODO: - 커스텀 셀을 생성하여 장소 리스트에 재사용
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        return cell
        
    }
    
    // MARK: - SelectedPlaceListDelegate
    func didAppendPlace(places: [MapInfo]) {
        self.mapInfoList = places
        tableView.reloadData()
    }
    
    // MARK: - Methods
    @objc func saveButtonTapped() {
        // TODO: - Plan 데이터 저장
        self.navigationController?.popViewController(animated: true)
    }
    
    func dateChanged() {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.dateStyle = .medium
        dateFormatter.dateFormat = "yyyy년 MM월 dd일"
        let selectedDate = dateFormatter.string(from: datePicker.date)
        
        dateField.text = selectedDate
        dateField.resignFirstResponder()
    }
    
    func inviteButtonTapped() {
        let addFriendTableViewController = AddFriendTableViewController()
        let navigationController = UINavigationController(rootViewController: addFriendTableViewController)
        present(navigationController, animated: true)
    }

    func addMapButtonTapped() {
        show(mapViewController, sender: nil)
    }
}
