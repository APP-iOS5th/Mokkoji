//
//  ProfileViewController.swift
//  Mokkoji
//
//  Created by 육현서 on 6/11/24.
//

import UIKit
import KakaoSDKUser
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import FirebaseStorage
//TODO: - 고객센터 (가이드, 문의하기, 서비스정책, 앱버전 등) 뷰 연결
extension UIImageView {
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}

class ProfileViewController: UIViewController {
    
    //MARK: - Properties
    let db = Firestore.firestore()  //firestore
    var userProfileImage = UserInfo.shared.user!.profileImageUrl
    let sectionTitle = ["가이드", "문의하기", "서비스정책", "앱버전"]
    
    //MARK: - UIComponents
    /// 프로필 이미지
    private lazy var profileImageView: UIImageView! = {
        let image = UIImageView()
        if let profileImageUrl = UserInfo.shared.user?.profileImageUrl,
           let url = URL(string: profileImageUrl.absoluteString) {
            image.load(url: url)
        }
        image.clipsToBounds = true
        image.layer.borderWidth = 2
        image.contentMode = .scaleAspectFill
        image.layer.borderColor = UIColor.white.cgColor
        image.layer.cornerRadius = 50
        return image
    }()
    
    /// 로그아웃 버튼
    private lazy var logoutButton: UIButton = {
        let button = UIButton()
        button.setTitle("LOGOUT", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.backgroundColor = UIColor(named: "Primary_Color")?.cgColor
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(logoutButtonTapped), for: .touchUpInside)
        return button
    }()
    
    /// 이름 레이블
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Name:"
        return label
    }()
    
    private lazy var nameCheck: UILabel! = {
        let label = UILabel()
        if let userName = UserInfo.shared.user?.name {
            label.text = "\(userName)"
        } else {
            label.text = "No Name"
        }
        label.numberOfLines = 2
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    /// 이메일 레이블
    private lazy var mailLabel: UILabel = {
        let label = UILabel()
        label.text = "E-mail:"
        return label
    }()
    
    private lazy var mailCheck: UILabel! = {
        let label = UILabel()
        if let userEmail = UserInfo.shared.user?.email {
            label.text = "\(userEmail)"
        } else {
            label.text = "No Email"
        }
        label.numberOfLines = 2
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    /// 친구 확인 테이블 뷰
    private lazy var customerServiceTableView: UITableView = {
        var tableView = UITableView()
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        // 네비게이션 바 타이틀 & 설정 버튼
        self.navigationItem.title = "PROFILE"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.largeTitleDisplayMode = .always
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "gearshape"), style: .plain, target: self, action: #selector(tapButtonProfileEdit))
        
        customerServiceTableView.dataSource = self
        customerServiceTableView.delegate = self
        customerServiceTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        view.addSubview(profileImageView)
        view.addSubview(nameLabel)
        view.addSubview(nameCheck)
        view.addSubview(mailLabel)
        view.addSubview(mailCheck)
        view.addSubview(logoutButton)
        view.addSubview(customerServiceTableView)
        
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameCheck.translatesAutoresizingMaskIntoConstraints = false
        mailLabel.translatesAutoresizingMaskIntoConstraints = false
        mailCheck.translatesAutoresizingMaskIntoConstraints = false
        customerServiceTableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            profileImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            profileImageView.widthAnchor.constraint(equalToConstant: 100),
            profileImageView.heightAnchor.constraint(equalToConstant: 100),
            
            nameLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            nameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 10),
            
            nameCheck.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            nameCheck.leadingAnchor.constraint(equalTo: nameLabel.trailingAnchor, constant: 10),
            nameCheck.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            mailLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 10),
            mailLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 10),
            
            mailCheck.topAnchor.constraint(equalTo: nameCheck.bottomAnchor, constant: 10),
            mailCheck.leadingAnchor.constraint(equalTo: mailLabel.trailingAnchor, constant: 10),
            mailCheck.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            logoutButton.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 20),
            logoutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoutButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            logoutButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            customerServiceTableView.topAnchor.constraint(equalTo: logoutButton.bottomAnchor, constant: 10),
            customerServiceTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            customerServiceTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            customerServiceTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100)
        ])
    }
    
    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(true)
        
        fetchProfileData()
    }
    
    //MARK: - Methods
    
    func fetchProfileData() {
        guard let user = UserInfo.shared.user else {
            return
        }
        self.fetchUserFromFirestore(userId: user.id) { fetchedUser in
            guard let fetchedUser = fetchedUser else { return }
            UserInfo.shared.user = fetchedUser
            
            DispatchQueue.main.async {
                self.profileImageView.load(url: fetchedUser.profileImageUrl)
                self.nameCheck.text = fetchedUser.name
                self.mailCheck.text = fetchedUser.email
            }
        }
    }
    
    @objc private func tapButtonProfileEdit() {
        let profileEditViewController = ProfileEditViewController()
        let navController = UINavigationController(rootViewController: profileEditViewController)
        
        present(navController, animated: true)
    }
    
    //로그아웃 버튼 기능
    @objc func logoutButtonTapped() {
        
        //firebase logout
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            print("firebase logout success")
        } catch let signOutError as NSError {
            print("Error signing out: \(signOutError)")
        }
        self.transitionToLoginView()
    }
    
    // 로그인 화면으로 전환
    func transitionToLoginView() {
        guard let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate else { return }
        let loginViewController = LoginViewController()
        let navController = UINavigationController(rootViewController: loginViewController)
        sceneDelegate.changeRootViewController(navController, animated: true)
    }
    
    //친구 추가 페이지 이동
    @objc func friendsPlusButton() {
        let friendsViewController = AddFriendViewController()
        self.navigationController?.pushViewController(friendsViewController, animated: true)
        
    }
}

//MARK: - UITableViewDelegate, DataSource Methods
extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionTitle.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = sectionTitle[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .white
        lazy var headerLabel: UILabel = {
            let label = UILabel()
            label.text = "고객센터"
            label.textAlignment = .left
            label.font = UIFont.boldSystemFont(ofSize: 12)
            label.textColor = .lightGray
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()
        
        headerView.addSubview(headerLabel)
        
        NSLayoutConstraint.activate([
            headerLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            headerLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            headerLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            headerLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16)
        ])
        
        return headerView
    }
}

extension ProfileViewController {
    func fetchUserFromFirestore(userId: String, completion: @escaping (User?) -> Void) {
        let userRef = db.collection("users").document(userId)
        userRef.getDocument { (document, error) in
            if let document = document, document.exists {
                do {
                    let user = try document.data(as: User.self)
                    completion(user)
                } catch let error {
                    print("User Decoding Error: \(error)")
                    completion(nil)
                }
            } else {
                print("Firestore에 User가 존재하지 않음.")
                completion(nil)
            }
        }
    }
}
