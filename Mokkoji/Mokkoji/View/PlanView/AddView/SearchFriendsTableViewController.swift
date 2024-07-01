//
//  SearchFriendsTableViewController.swift
//  Mokkoji
//
//  Created by 박지혜 on 6/20/24.
//

import UIKit

/// 임시 데이터
struct sampleFriend {
    static var friends = [
        User(id: "123", name: "김홍도", email: "asd@asd.com", profileImageUrl: URL(string: "https://picsum.photos/200/300")!),
        User(id: "1234", name: "김홍만", email: "asd@asd.com", profileImageUrl: URL(string: "https://picsum.photos/200/300")!),
        User(id: "1235", name: "김홍기", email: "asd@asd.com", profileImageUrl: URL(string: "https://picsum.photos/200/300")!)
    ]
}

protocol SelectedFriendListDelegate {
    func didSelectFriends(user: User)
}

class SearchFriendsTableViewController: UITableViewController, UISearchResultsUpdating {
    
//    var friends: [User] = UserInfo.shared.user?.friendList ?? []
    var friends: [User] = sampleFriend.friends
    var filteredFriends: [User] = []
    
    var delegate: SelectedFriendListDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// FriendListViewCell 등록
        tableView.register(FriendListTableViewCell.self, forCellReuseIdentifier: "friendCell")
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredFriends.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "friendCell", for: indexPath) as? FriendListTableViewCell else {
            return UITableViewCell()
        }
        
        let image = filteredFriends[indexPath.row].profileImageUrl
        let name = filteredFriends[indexPath.row].name
        let email = filteredFriends[indexPath.row].email
        
        cell.configure(friendImage: image, friendName: name, friendEmail: email)

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        /// 행 선택 시 버튼 이미지 변경
        guard let cell = tableView.cellForRow(at: indexPath) as? FriendListTableViewCell else {
            return
        }
        let config = UIImage.SymbolConfiguration(pointSize: 30, weight: .regular, scale: .default)
        let buttonImage = UIImage(systemName: "plus.circle.fill", withConfiguration: config)
        cell.inviteButton.setImage(buttonImage, for: .normal)
        
        /// 선택한 친구 목록 저장 및 전달
        delegate?.didSelectFriends(user: filteredFriends[indexPath.row])
        
        dismiss(animated: true)
    }
    
    // MARK: - UISearchResultsUpdating
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text,
              !searchText.isEmpty {
            filteredFriends = friends.filter { friend in
                return friend.name.contains(searchText)
            }
        } else {
            filteredFriends.removeAll()
        }
        
        tableView.reloadData()
    }
                        
}
