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
    var selectedPlan: Plan? // 추가된 속성
    
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
        var selectedFriend = friends[indexPath.row]
        // 공유 기능 구현
        sharePlan(with: &selectedFriend)
    }
    
    //약
    func sharePlan(with friend: inout User) {
        guard let plan = selectedPlan else {
            print("선택된 약속이 없습니다.")
            return
        }

        if friend.sharedPlan == nil {
            friend.sharedPlan = []
        }
        
        friend.sharedPlan?.append(plan)
        
        print("\(friend.name)에게 약속을 공유했습니다.")
        print("\(plan)")
        
        dismiss(animated: true, completion: nil)
    }
}
