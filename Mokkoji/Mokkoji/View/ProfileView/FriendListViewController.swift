//
//  AddFriendViewController.swift
//  Mokkoji
//
//  Created by 육현서 on 6/11/24.
//

import UIKit

class FriendListViewController: UIViewController{
        
    //MARK: - UIComponents
    
    ///친구목록 테이블
    private lazy var friendSearchTableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(FriendTableViewCell.self, forCellReuseIdentifier: "friendCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    //친구목록이 비어있을때 레이블
    private lazy var isEmptyFriendLabel: UILabel = {
        let label = UILabel()
        label.text = "친구목록이 비어있습니다."
        label.textAlignment = .center
        label.textColor = .black
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        self.navigationItem.title = "FRIENDS"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "person.badge.plus"), style: .plain, target: self, action: #selector(addFriendButtonTapped))
        
        view.addSubview(friendSearchTableView)
        view.addSubview(isEmptyFriendLabel)
        
        NSLayoutConstraint.activate([
            isEmptyFriendLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            isEmptyFriendLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            isEmptyFriendLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            
            friendSearchTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            friendSearchTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            friendSearchTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        updateEmptyFriendLabel()
        print("friendList: \(UserInfo.shared.user?.friendList)")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        friendSearchTableView.reloadData()
    }
    
    //MARK: - Methods
    @objc func addFriendButtonTapped() {
        let addFriendViewController = AddFriendViewController()
        present(addFriendViewController, animated: true)
    }
    
    private func updateEmptyFriendLabel() {
        if let friendList = UserInfo.shared.user?.friendList, !friendList.isEmpty {
            isEmptyFriendLabel.isHidden = true
        } else {
            isEmptyFriendLabel.isHidden = false
        }
    }
}

//MARK: - UITableViewDelegate, DataSource Methods
extension FriendListViewController: UITableViewDelegate, UITableViewDataSource {
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
}