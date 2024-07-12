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
    

    
    //MARK: - UIComponents
    /// 프로필 이미지
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
    
    /// 로그아웃 버튼
    let logoutButton: UIButton = {
        let button = UIButton()
        button.setTitle("LOGOUT", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.backgroundColor = UIColor(named: "Primary_Color")?.cgColor
        button.layer.cornerRadius = 10
        button.addTarget(ProfileViewController.self, action: #selector(logoutButtonTapped), for: .touchUpInside)
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
    
    /// 친구 삭제 버튼
    private lazy var deleteFriendButton: UIButton = {
        let button = UIButton()
        button.setTitle("친구삭제", for: .normal)
        button.setTitle("완료", for: .selected)
        button.setTitleColor(UIColor(named: "Primary_Color"), for: .normal)
        button.setTitleColor(.blue, for: [.normal, .highlighted])
        button.setTitleColor(.systemRed, for: .selected)
        button.setTitleColor(.red, for: [.selected, .highlighted])
        button.addTarget(self, action: #selector(friendsDeleteButton), for: .touchUpInside)
        return button
    }()
    
    /// 친구 확인 테이블 뷰
    private lazy var friendsTableView: UITableView = {
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
        
        friendsTableView.dataSource = self
        friendsTableView.delegate = self
        friendsTableView.register(FriendTableViewCell.self, forCellReuseIdentifier: "friendCell")
        
        view.addSubview(profileImageView)
        view.addSubview(nameLabel)
        view.addSubview(nameCheck)
        view.addSubview(mailLabel)
        view.addSubview(mailCheck)
        view.addSubview(logoutButton)
        view.addSubview(deleteFriendButton)
        view.addSubview(friendsTableView)
        
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameCheck.translatesAutoresizingMaskIntoConstraints = false
        mailLabel.translatesAutoresizingMaskIntoConstraints = false
        mailCheck.translatesAutoresizingMaskIntoConstraints = false
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
            
            deleteFriendButton.topAnchor.constraint(equalTo: logoutButton.bottomAnchor, constant: 10),
            deleteFriendButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            friendsTableView.topAnchor.constraint(equalTo: deleteFriendButton.bottomAnchor, constant: 10),
            friendsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            friendsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            friendsTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100)
        ])
    }
    
    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(true)
        
        fetchProfileData()
        
        if let friendList = UserInfo.shared.user?.friendList {
            if friendList.count == 0 {
                let emptyFriend = [User(id: "123", name: "친구목록이 비어있습니다.", email: "asd@asd.com", profileImageUrl:URL(string: "https://postfiles.pstatic.net/MjAyMDA5MDNfNzYg/MDAxNTk5MTI1ODQyOTgz.GcnIG2lAeKYjlf_WW__Z-RbcEmuCPliCM7JtSvcSf9Eg.IfoEGxCaenu31xJE57uGvHnwOqANmAIW_Azf2oIYxDMg.PNG.shshspdla/1%EB%8C%801.png?type=w773")!)]
                UserInfo.shared.user?.friendList = emptyFriend
            }
        } else {
            let emptyFriend = [User(id: "123", name: "친구목록이 비어있습니다.", email: "asd@asd.com", profileImageUrl:URL(string: "https://postfiles.pstatic.net/MjAyMDA5MDNfNzYg/MDAxNTk5MTI1ODQyOTgz.GcnIG2lAeKYjlf_WW__Z-RbcEmuCPliCM7JtSvcSf9Eg.IfoEGxCaenu31xJE57uGvHnwOqANmAIW_Azf2oIYxDMg.PNG.shshspdla/1%EB%8C%801.png?type=w773")!)]
            UserInfo.shared.user?.friendList = emptyFriend
        }
        friendsTableView.reloadData()
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

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    //친구 테이블 뷰
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
          
          let imageSize: CGFloat = 50
          cell.imageView?.frame = CGRect(x: 0, y: 0, width: imageSize, height: imageSize)
          cell.imageView?.layer.cornerRadius = imageSize / 3.6
          cell.imageView?.clipsToBounds = true
          cell.selectionStyle = .none
          
          return cell
      }
      
    
    //친구 삭제
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
