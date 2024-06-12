//
//  infoFriendViewController.swift
//  Mokkoji
//
//  Created by 차지용 on 6/12/24.
//

import UIKit

class InfoFriendViewController: UIViewController, UITableViewDataSource,UITableViewDelegate {

    let tableView = UITableView()
    var friends: [User] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "friendCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "friendCell", for: indexPath)
        cell.textLabel?.text = friends[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedFriend = friends[indexPath.row]
        // 공유 기능 구현
        sharePlan(with: selectedFriend)
    }

    func sharePlan(with friend: User) {
        // 공유 기능 구현 (예시: 콘솔에 출력)
        print("\(friend.name)에게 약속을 공유했습니다.")
    }
}
