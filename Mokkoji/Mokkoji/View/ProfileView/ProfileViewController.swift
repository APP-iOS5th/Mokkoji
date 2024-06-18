//
//  ProfileViewController.swift
//  Mokkoji
//
//  Created by 육현서 on 6/11/24.
//

import UIKit
import KakaoSDKUser
import FirebaseAuth

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


class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var userProfileImage = UserInfo.shared.user!.profileImageUrl
    
    var myMail: String? {
        didSet {
            mailCheck.text = myMail
        }
    }
    
    var myName: String? {
        didSet {
            nameCheck.text = myName
        }
    }
    
    var myImage: UIImage? {
        didSet {
            profileImageView.image = myImage
        }
    }
    
    // MARK: - 프로필 사진
    let profileImageView: UIImageView! = {
        let image = UIImageView()
        
        image.image = UIImage(systemName: "person.circle")
        image.clipsToBounds = true
        image.layer.borderWidth = 2
        image.contentMode = .scaleAspectFill
        image.layer.borderColor = UIColor.white.cgColor
        image.layer.cornerRadius = 50
        
        return image
    }()
    
    // MARK: - 로그아웃 버튼
    let logoutButton: UIButton = {
        let button = UIButton()
        
        button.setTitle("LOGOUT", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.backgroundColor = UIColor.systemBlue.cgColor
        button.layer.cornerRadius = 10
        
        button.addTarget(self, action: #selector(kakaoLogoutButtonTapped), for: .touchUpInside)
        
        return button
    }()
    
    // MARK: - 이름 라벨
    private lazy var nameLabel: UILabel = {
        let nameL = UILabel()
        nameL.text = "Name:"
        
        return nameL
    }()
    
    private lazy var nameCheck: UILabel! = {
        let nameLabel = UILabel()
        if let userName = UserInfo.shared.user?.name {
            nameLabel.text = "\(userName)"
        } else {
            nameLabel.text = "No Name"
        }
        
        nameLabel.numberOfLines = 2
        nameLabel.lineBreakMode = .byWordWrapping
        
        return nameLabel
    }()
    
    // MARK: - 이메일 라벨
    private lazy var mailLabel: UILabel = {
        let mailL = UILabel()
        mailL.text = "E-mail:"
        
        return mailL
    }()
    
    private lazy var mailCheck: UILabel! = {
        let mailLabel = UILabel()
        if let userEmail = UserInfo.shared.user?.email {
            mailLabel.text = "\(userEmail)"
        } else {
            mailLabel.text = "No Email"
        }
        
        mailLabel.numberOfLines = 2
        mailLabel.lineBreakMode = .byWordWrapping
        
        return mailLabel
    }()
    
    // MARK: - 친구 추가 버튼
    private lazy var addFriendButton: UIButton = {
        let plusButton = UIButton()
        plusButton.setTitle("친구추가 +", for: .normal)
        plusButton.setTitleColor(.systemBlue, for: .normal)
        plusButton.addTarget(self, action: #selector(friendsPlusButton), for: .touchUpInside)
        
        return plusButton
    }()
    
    // MARK: - 친구 삭제 버튼
    private lazy var deleteFriendButton: UIButton = {
        let deleteButton = UIButton()
        
        deleteButton.setTitle("친구삭제", for: .normal)
        deleteButton.setTitle("완료", for: .selected)
        
        deleteButton.setTitleColor(.systemBlue, for: .normal)
        deleteButton.setTitleColor(.blue, for: [.normal, .highlighted])
        
        deleteButton.setTitleColor(.systemRed, for: .selected)
        deleteButton.setTitleColor(.red, for: [.selected, .highlighted])
        
        deleteButton.addTarget(self, action: #selector(friendsDeleteButton), for: .touchUpInside)
        
        
        return deleteButton
    }()
    
    // MARK: - 친구 확인 테이블 뷰
    private lazy var friendsTableView: UITableView = {
        var tableView = UITableView()
        
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        // MARK: - 네비게이션 바 타이틀 & 설정 버튼
        self.navigationItem.title = "PROFILE"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.largeTitleDisplayMode = .always
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "gearshape"), style: .plain, target: self, action: #selector(tapButtonProfileEdit))
        
        friendsTableView.dataSource = self
        friendsTableView.delegate = self
        friendsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "friendCell")
        
        view.addSubview(profileImageView)
        view.addSubview(nameLabel)
        view.addSubview(nameCheck)
        view.addSubview(mailLabel)
        view.addSubview(mailCheck)
        view.addSubview(logoutButton)
        view.addSubview(addFriendButton)
        view.addSubview(deleteFriendButton)
        view.addSubview(friendsTableView)
        
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameCheck.translatesAutoresizingMaskIntoConstraints = false
        mailLabel.translatesAutoresizingMaskIntoConstraints = false
        mailCheck.translatesAutoresizingMaskIntoConstraints = false
        addFriendButton.translatesAutoresizingMaskIntoConstraints = false
        deleteFriendButton.translatesAutoresizingMaskIntoConstraints = false
        friendsTableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            profileImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            profileImageView.widthAnchor.constraint(equalToConstant: 100),
            profileImageView.heightAnchor.constraint(equalToConstant: 100),
            
            nameLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            nameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 10),
            
            nameCheck.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            nameCheck.leadingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            nameCheck.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            mailLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 10),
            mailLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 10),
            
            mailCheck.topAnchor.constraint(equalTo: nameCheck.bottomAnchor, constant: 10),
            mailCheck.leadingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            mailCheck.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            logoutButton.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 20),
            logoutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoutButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            logoutButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            addFriendButton.topAnchor.constraint(equalTo: logoutButton.bottomAnchor, constant: 10),
            addFriendButton.trailingAnchor.constraint(equalTo: deleteFriendButton.leadingAnchor, constant: -10),
            
            deleteFriendButton.topAnchor.constraint(equalTo: logoutButton.bottomAnchor, constant: 10),
            deleteFriendButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            friendsTableView.topAnchor.constraint(equalTo: deleteFriendButton.bottomAnchor, constant: 10),
            friendsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            friendsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            friendsTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100)
        ])
    }
    
    override func viewIsAppearing(_ animated: Bool) {
        profileImageView.load(url: userProfileImage)
        if let userFriend = UserInfo.shared.user?.friendList {
            
        } else { // TODO: - 친구 목록이 비어있을땐 이미지가 나오면 안됨 (수정중)
            let emptyFriend = [User(id: "123", name: "친구목록이 비어있습니다.", email: "asd@asd.com", profileImageUrl: URL(string: "")!)]
            UserInfo.shared.user?.friendList = emptyFriend
        }
        friendsTableView.reloadData()
    }
    
    // TODO: - 프로필 편집 페이지로 이동 & 편집 저장된 데이터 불러오기 기능 (?) 확인 필요
    @objc private func tapButtonProfileEdit() {
        let profileEditViewController = ProfileEditViewController()
        let navController = UINavigationController(rootViewController: profileEditViewController)
        
        profileEditViewController.onSave = { [weak self] text, text2, image1 in
            self?.myName = text
            self?.myMail = text2
            self?.myImage = image1
        }
        present(navController, animated: true)
    }
    
    // MARK: - 로그아웃 버튼 기능
    @objc func kakaoLogoutButtonTapped() {
        //kakaoLogout
        UserApi.shared.logout{(error) in
            if let error = error {
                print(error)
            } else {
                print("kakao logout success")
            }
        }
        
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
    
    // 로그인 화면으로 전환하는 함수
    func transitionToLoginView() {
        let loginViewController = LoginViewController()
        loginViewController.modalPresentationStyle = .fullScreen
        self.present(loginViewController, animated: true, completion: nil)
    }
    
    // MARK: - 친구 추가 페이지 이동
    @objc func friendsPlusButton() {
        let friendsViewController = AddFriendViewController()
        self.navigationController?.pushViewController(friendsViewController, animated: true)
        
    }
    
    // MARK: - 친구 테이블 뷰
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return UserInfo.shared.user?.friendList?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "friendCell", for: indexPath)
        guard let cellImage = UserInfo.shared.user?.friendList?[indexPath.row].profileImageUrl else {
            return UITableViewCell()
        }
        
        cell.textLabel?.text = UserInfo.shared.user?.friendList?[indexPath.row].name
        cell.imageView?.image = UIImage(systemName: "person.circle")
        cell.imageView?.load(url: cellImage)
        
        return cell
    }
    
    // MARK: - 친구 삭제
    @objc func friendsDeleteButton() {
        let shouldBeEdited = !friendsTableView.isEditing
        friendsTableView.setEditing(shouldBeEdited, animated: true)
        deleteFriendButton.isSelected = shouldBeEdited
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return tableView.isEditing
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return tableView.isEditing ? .delete : .none
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        UserInfo.shared.user?.friendList?.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .fade)
    }
}
