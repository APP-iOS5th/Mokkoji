//
//  AddFriendViewController.swift
//  Mokkoji
//
//  Created by 육현서 on 6/11/24.
//

import UIKit

class AddFriendViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
 
    var allFriends = [User(id: "123", name: "김홍도", email: "asd@asd.com", profileImageUrl: URL(string: "https://picsum.photos/200/300")!),
                          User(id: "1234", name: "김홍만", email: "asd@asd.com", profileImageUrl: URL(string: "https://picsum.photos/200/300")!),
                          User(id: "1235", name: "김홍기", email: "asd@asd.com", profileImageUrl: URL(string: "https://picsum.photos/200/300")!)
                          ]
    var filteredFriends = [User]()
    
    private lazy var friendSearchBar: UISearchBar = {
        let searchBar = UISearchBar()
        
        return searchBar
    }()
    
    private lazy var friendSearchTableView: UITableView = {
        let tableView = UITableView()
        
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        self.navigationItem.title = "FRIENDS"
        
        view.addSubview(friendSearchBar)
        view.addSubview(friendSearchTableView)
        
        friendSearchBar.translatesAutoresizingMaskIntoConstraints = false
        friendSearchTableView.translatesAutoresizingMaskIntoConstraints = false
        
        friendSearchBar.delegate = self
        
        friendSearchTableView.delegate = self
        friendSearchTableView.dataSource = self
        friendSearchTableView.register(UITableViewCell.self, forCellReuseIdentifier: "friendCell")
        friendSearchTableView.reloadData()
        
        filteredFriends = allFriends
        
        NSLayoutConstraint.activate([
            friendSearchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            friendSearchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            friendSearchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            friendSearchTableView.topAnchor.constraint(equalTo: friendSearchBar.bottomAnchor),
            friendSearchTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            friendSearchTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            friendSearchTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            
        ])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        friendSearchTableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if UserInfo.shared.user?.friendList?.first?.name == "친구목록이 비어있습니다." {
            UserInfo.shared.user?.friendList?.removeFirst()
        }
    }
    
    // TODO: - 검색창 기능 구현
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        if searchText.isEmpty {
//            filteredFriends = allFriends
//        } else {
//            filteredFriends = allFriends.filter { $0.name.contains(searchText) }
//        }
//        friendSearchTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allFriends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "friendCell", for: indexPath)
        let cellImage = allFriends[indexPath.row].profileImageUrl
        
        cell.textLabel?.text = allFriends[indexPath.row].name
        cell.imageView?.image = UIImage(systemName: "person.circle")
        cell.imageView?.load(url: cellImage)
        print(cell.imageView)

        return cell
    }
    
    // MARK: - 셀 클릭하면 알람 + yes 선택 시 profileViewController에 친구 cell 추가
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let alertController = UIAlertController(title: "Add Friend", message: "\(allFriends[indexPath.row].name)을 친구목록에 추가 하시겠습니까?", preferredStyle: .alert)

        let yesAction = UIAlertAction(title: "Yes", style: .default) { _ in
            print("Yes")
            print(indexPath.row)
            if UserInfo.shared.user?.name != nil {
                var newFriend = User(id: self.allFriends[indexPath.row].id, name: self.allFriends[indexPath.row].name, email: self.allFriends[indexPath.row].email, profileImageUrl: self.allFriends[indexPath.row].profileImageUrl)
                
                UserInfo.shared.user!.friendList?.append(newFriend)
                
                print("현재 추가된 친구리스트 \(UserInfo.shared.user?.friendList)")
                print("현재 추가된 친구리스트 \(newFriend)")
                self.navigationController?.popViewController(animated: true)
            } else {
                
            }
            
        }

        let noAction = UIAlertAction(title: "No", style: .cancel) { _ in
           // self.dismiss(animated: true)
            print("No")
        }

        alertController.addAction(yesAction)
        alertController.addAction(noAction)

        present(alertController, animated: true, completion: nil)
    }
}
