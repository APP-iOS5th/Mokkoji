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

class AddPlanViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
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
        datePicker.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 400)
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        
        datePicker.addAction(UIAction { [weak self] _ in
            self?.dateChanged()
        }, for: .valueChanged)
        return datePicker
    }()
    
    lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    lazy var profileImage: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    lazy var inviteButton: UIButton = {
        let button = UIButton()
        
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var addMapButton: UIButton = {
        let button = UIButton()
        
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var mapView: UIImageView = {
        let imageView = UIImageView()
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(AddPlanInfoTableViewCell.self, forCellReuseIdentifier: "addPlanInfoCell")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        self.navigationItem.title = "약속 추가"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveButtonTapped))
        
        stackView.addArrangedSubview(profileImage)
        stackView.addArrangedSubview(inviteButton)
        
        self.view.addSubview(titleText)
        self.view.addSubview(bodyText)
        self.view.addSubview(dateField)
        self.view.addSubview(stackView)
        self.view.addSubview(addMapButton)
        self.view.addSubview(mapView)
        self.view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            titleText.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleText.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            titleText.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
        
            bodyText.topAnchor.constraint(equalTo: titleText.bottomAnchor, constant: 5),
            bodyText.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            bodyText.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            
            dateField.topAnchor.constraint(equalTo: bodyText.bottomAnchor, constant: 5),
            dateField.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            dateField.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            
            profileImage.widthAnchor.constraint(equalToConstant: 50),
            profileImage.heightAnchor.constraint(equalToConstant: 50),
            
            stackView.topAnchor.constraint(equalTo: dateField.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            
            addMapButton.topAnchor.constraint(equalTo: stackView.bottomAnchor),
            addMapButton.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            addMapButton.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            
            mapView.topAnchor.constraint(equalTo: addMapButton.bottomAnchor),
            mapView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            mapView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            mapView.heightAnchor.constraint(equalToConstant: 200),
            
            tableView.topAnchor.constraint(equalTo: mapView.bottomAnchor),
            tableView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            tableView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -20)
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
        // TODO: - 장소 수로 변경
        5
        
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // TODO: - 커스텀 셀을 생성하여 장소 리스트에 재사용
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        return cell
        
    }
    
    // MARK: - Methods
    @objc func saveButtonTapped() {
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

    
}
