//
//  AddFriendViewController.swift
//  Mokkoji
//
//  Created by 육현서 on 6/11/24.
//

import UIKit

class AddFriendViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    var allFriends = ["a1", "b2", "c3", "d4", "e5", "f6", "g7", "h8", "i9", "j10", "k11", "l12"]
    var filteredFriends = [String]()
    
    private lazy var friendSearchBar: UISearchBar = {
        let searchBar = UISearchBar()
        
        return searchBar
    }()
    
    private lazy var friendSearchTableView: UITableView = {
        let tableView = UITableView()
        
        return tableView
    }()
    
    let tableView = UITableView()
    
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
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredFriends = allFriends
        } else {
            filteredFriends = allFriends.filter { $0.contains(searchText) }
        }
        friendSearchTableView.reloadData()
    }
    
    // UITableViewDataSource methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredFriends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "friendCell", for: indexPath)
        cell.textLabel?.text = filteredFriends[indexPath.row]
        cell.imageView?.image = UIImage(systemName: "person.circle")
        return cell
    }
}


