//
//  AddFriendViewController.swift
//  Mokkoji
//
//  Created by 육현서 on 6/11/24.
//

import UIKit

class AddFriendViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    var allFriends = [
        User(id: "123", name: "김홍도", email: "asd@asd.com", profileImageUrl: URL(string: "https://picsum.photos/200/300")!),
        User(id: "1234", name: "김홍만", email: "asd@asd.com", profileImageUrl: URL(string: "https://picsum.photos/200/300")!),
        User(id: "1235", name: "김홍기", email: "asd@asd.com", profileImageUrl: URL(string: "https://picsum.photos/200/300")!)
    ]
    
    var filteredFriends = [User]()
    
    private lazy var friendSearchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.delegate = self
        return searchBar
    }()
    
    private lazy var friendSearchTableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "friendCell")
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
        super.viewWillAppear(animated)
        friendSearchTableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if UserInfo.shared.user?.friendList?.first?.name == "친구목록이 비어있습니다." {
            UserInfo.shared.user?.friendList?.removeFirst()
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredFriends = allFriends
        } else {
            filteredFriends = allFriends.filter { $0.name.contains(searchText) }
        }
        friendSearchTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredFriends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "friendCell", for: indexPath)
        let friend = filteredFriends[indexPath.row]
        
        cell.textLabel?.text = friend.name
        cell.imageView?.image = UIImage(systemName: "person.circle")
        cell.imageView?.load(url: friend.profileImageUrl)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedFriend = filteredFriends[indexPath.row]
        let alertController = UIAlertController(title: "Add Friend", message: "\(selectedFriend.name)을 친구목록에 추가 하시겠습니까?", preferredStyle: .alert)

        let yesAction = UIAlertAction(title: "Yes", style: .default) { _ in
            if UserInfo.shared.user?.name != nil {
                UserInfo.shared.user?.friendList?.append(selectedFriend)
                self.navigationController?.popViewController(animated: true)
            } else {
                // 이미 있는 사람은 추가하면 안됨 ..
            }
        }

        let noAction = UIAlertAction(title: "No", style: .cancel)

        alertController.addAction(yesAction)
        alertController.addAction(noAction)

        present(alertController, animated: true, completion: nil)
    }
}
