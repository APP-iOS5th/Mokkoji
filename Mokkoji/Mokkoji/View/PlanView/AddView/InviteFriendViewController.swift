//
//  AddFriendViewController.swift
//  Mokkoji
//
//  Created by 박지혜 on 6/11/24.
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

class InviteFriendTableViewController: UITableViewController, UISearchResultsUpdating {
    
//    var friends: [User] = UserInfo.shared.user?.friendList ?? []
    var friends: [User] = sampleFriend.friends
    var filteredFriends: [User] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        self.title = "친구 목록"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelTapped))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneTapped))
        
        /// 검색 컨트롤러
        let searchController = UISearchController(searchResultsController: nil)
        /// 텍스트가 변경될 때마다 업데이트를 처리
        searchController.searchResultsUpdater = self
        /// 검색바가 활성화될 때 검색 결과 뷰의 배경을 흐리게 하지 않음
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "친구 이름을 검색해보세요."
        self.navigationItem.searchController = searchController
        definesPresentationContext = true
        
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

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    */
    
    // MARK: - UISearchResultsUpdating
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        let searchText = searchBar.text ?? ""
        filteredSearchText(searchText)
    }

    
    // MARK: - Methods
    @objc func cancelTapped() {
        dismiss(animated: true)
    }
    
    @objc func doneTapped() {
        dismiss(animated: true)
    }
    
    func filteredSearchText(_ searchText: String) {
        if searchText.isEmpty {
            filteredFriends = friends
        } else {
//            filteredFriends = friends.filter { $0 in
//                return $0.friendList.lowercased().contains(searchText.lowercased())
            print("1")
                
        }
        tableView.reloadData()
    }
                            

    

}

