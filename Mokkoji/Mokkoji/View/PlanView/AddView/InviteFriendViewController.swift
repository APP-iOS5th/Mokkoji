//
//  AddFriendViewController.swift
//  Mokkoji
//
//  Created by 박지혜 on 6/11/24.
//

import UIKit

class InviteFriendTableViewController: UITableViewController, SelectedFriendListDelegate {

    var selectedFriends: [User] = []
    
    /// 검색 결과 컨트롤러
    let searchFriendsTableViewController = SearchFriendsTableViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        self.title = "친구 목록"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelTapped))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneTapped))
        
        // 검색 컨트롤러
        let searchController = UISearchController(searchResultsController: searchFriendsTableViewController)
        /// 텍스트가 변경될 때마다 업데이트를 처리
        searchController.searchResultsUpdater = searchFriendsTableViewController
        searchFriendsTableViewController.delegate = self

        searchController.searchBar.placeholder = "친구 이름을 검색해보세요."
        /// 스크롤 시 searchBar를 숨기지 않도록 설정
        self.navigationItem.hidesSearchBarWhenScrolling = false
        self.navigationItem.searchController = searchController
        
        // FriendListViewCell 등록
        tableView.register(FriendListTableViewCell.self, forCellReuseIdentifier: "friendCell")
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedFriends.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "friendCell", for: indexPath) as? FriendListTableViewCell else {
            return UITableViewCell()
        }
        
        let image = selectedFriends[indexPath.row].profileImageUrl
        let name = selectedFriends[indexPath.row].name
        let email = selectedFriends[indexPath.row].email
        
        cell.configure(friendImage: image, friendName: name, friendEmail: email)

        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // 행 삭제
            selectedFriends.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    // MARK: - SelectedFriendListDelegate
    func didInviteFriends(user: User) {
//        self.selectedFriends = users
        selectedFriends.append(user)
        
        tableView.reloadData()
    }
    
    // MARK: - Methods
    @objc func cancelTapped() {
        dismiss(animated: true)
    }
    
    @objc func doneTapped() {
        dismiss(animated: true)
    }
        
}
