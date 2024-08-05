//
//  AddFriendViewController.swift
//  Mokkoji
//
//  Created by 정종원 on 7/14/24.
//

import UIKit
import FirebaseFirestore

class AddFriendViewController: UIViewController {
    
    //MARK: - Properties
    let db = Firestore.firestore()  //firestore
    var filteredFriends = [User]()
    
    //텍스트가 있을 경우만 true
    var isFiltering: Bool {
        return !(friendSearchBar.text?.isEmpty ?? true)
    }
    
    //MARK: - UIComponents
    private lazy var friendSearchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.delegate = self
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
    }()
    
    private lazy var friendSearchTableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(FriendTableViewCell.self, forCellReuseIdentifier: "friendCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    //MARK: - View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        self.hideKeyboardWhenTappedAround()
        
        view.addSubview(friendSearchBar)
        view.addSubview(friendSearchTableView)
        
        NSLayoutConstraint.activate([
            friendSearchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            friendSearchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            friendSearchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            friendSearchTableView.topAnchor.constraint(equalTo: friendSearchBar.bottomAnchor),
            friendSearchTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            friendSearchTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            friendSearchTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
    }
    
    //MARK: - Methods
    func searchFriendToFirestore(userEmail: String) {
        let friendsRef = db.collection("users").whereField("email", isEqualTo: userEmail)
        friendsRef.getDocuments { querySnapshot, error in
            do {
                for document in querySnapshot!.documents {
                    //                    print("\(document.documentID) => \(document.data())")
                    self.filteredFriends.append(try document.data(as: User.self))
                    print("Friend search success \(self.filteredFriends)")
                    
                }
                DispatchQueue.main.async {
                    self.friendSearchTableView.reloadData()
                }
            } catch {
                print("AddFriendVC [FB] get friend error: \(error)")
            }
        }
    }
}

//MARK: - UITableView Delegate, DataSource Methods
extension AddFriendViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.filteredFriends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "friendCell", for: indexPath)
        let cellImage = filteredFriends[indexPath.row].profileImageUrl
        
        cell.textLabel?.text = filteredFriends[indexPath.row].name
        cell.imageView?.image = UIImage(systemName: "person.circle")
        cell.imageView?.load(url: cellImage)
        
        let imageSize: CGFloat = 50
        cell.imageView?.frame = CGRect(x: 0, y: 0, width: imageSize, height: imageSize)
        cell.imageView?.layer.cornerRadius = imageSize / 3.6
        cell.imageView?.clipsToBounds = true
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //TODO: - 친구 중복 확인 추가 필요.
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard var user = UserInfo.shared.user else { return }
        var selectedFriend = filteredFriends[indexPath.row]
        
        let alertController = UIAlertController(title: "Add Friend", message: "\(selectedFriend.name)을 친구목록에 추가 하시겠습니까?", preferredStyle: .alert)
        
        let yesAction = UIAlertAction(title: "Yes", style: .default) { _ in
            
            if ((user.friendList?.contains(where: { $0.email == selectedFriend.email })) != nil) {
                //친구가 중복됨
            } else {
                // friendList가 nil이면 초기화
                if  user.friendList == nil {
                    print("friendList nil 초기화")
                    user.friendList = []
                }
                if selectedFriend.friendList == nil {
                    print("selectedFriend friendList nil 초기화")
                    selectedFriend.friendList = []
                }
                user.friendList?.append(selectedFriend)
                selectedFriend.friendList?.append(user)
                
                self.addFriendToFirestore(user: user, userEmail: user.email, friend: selectedFriend, friendEmail: selectedFriend.email)
                
                UserInfo.shared.user = user
                print("AddFriendView[FB] 친구 양방향 저장 성공")
            }
            self.dismiss(animated: true)
        }
        
        let noAction = UIAlertAction(title: "No", style: .cancel)
        
        alertController.addAction(yesAction)
        alertController.addAction(noAction)
        
        present(alertController, animated: true, completion: nil)
    }
}

//MARK: - UISearchBarDelegate Methods
extension AddFriendViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let userEmail = searchBar.text else { return }
        searchFriendToFirestore(userEmail: userEmail)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        searchBar.text = ""
        // 캔슬 버튼을 눌렀을 때도 역시 모든 영화가 나오게 한다
        filteredFriends.removeAll()
        
        DispatchQueue.main.async {
            self.friendSearchTableView.reloadData()
        }
        
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
    }
}

//MARK: - Keyboard Handling Methods
extension AddFriendViewController {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func keyboardWillHide(_ notification: NSNotification) {
        print("keyboard down")
        if view.frame.origin.y != 0 {
            view.frame.origin.y = 0
        }
    }
}

//MARK: - FireStore Methods
extension AddFriendViewController {
    
    func addFriendToFirestore(user: User, userEmail: String, friend: User, friendEmail: String) {
        let userRef = db.collection("users").document(userEmail)
        let friendRef = db.collection("users").document(friendEmail)
        do {
            try userRef.setData(from: user)
            try friendRef.setData(from: friend)
            print("[FB] addFriendToFirestore Success")
        } catch let error {
            print("Firestore 양방향 저장 Error: \(error)")
        }
    }
    
}
