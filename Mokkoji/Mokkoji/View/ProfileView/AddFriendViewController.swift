//
//  AddFriendViewController.swift
//  Mokkoji
//
//  Created by 정종원 on 7/14/24.
//

import UIKit

class AddFriendViewController: UIViewController {
    
    //MARK: - Properties
    var filteredFriends = [User]()
    
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
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
    }
    
    //MARK: - Methods
}

//MARK: - UITableView Delegate, DataSource Methods
extension AddFriendViewController: UITableViewDelegate, UITableViewDataSource {
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedFriend = filteredFriends[indexPath.row]
        let alertController = UIAlertController(title: "Add Friend", message: "\(selectedFriend.name)을 친구목록에 추가 하시겠습니까?", preferredStyle: .alert)
        
        print("\(selectedFriend)")
        let yesAction = UIAlertAction(title: "Yes", style: .default) { _ in
            if UserInfo.shared.user!.friendList!.isEmpty {
                UserInfo.shared.user!.friendList = [selectedFriend]
            } else {
                if !UserInfo.shared.user!.friendList!.contains(where: { $0.id == selectedFriend.id }) {
                    UserInfo.shared.user!.friendList!.append(selectedFriend)
                } else {
                    return
                }
            }
        }
        
        let noAction = UIAlertAction(title: "No", style: .cancel)
        
        alertController.addAction(yesAction)
        alertController.addAction(noAction)
        
        present(alertController, animated: true, completion: nil)
    }
}

//MARK: - UISearchBarDelegate Methods
extension AddFriendViewController: UISearchBarDelegate {
    
}
