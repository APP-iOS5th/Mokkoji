//
//  InfoFriendViewController.swift
//  Mokkoji
//
//  Created by 차지용 on 6/12/24.
//

import UIKit
import FirebaseFirestore
import Firebase

class InfoFriendViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    let tableView = UITableView()
    var friends: [User] = []
    var selectedPlan: Plan? // 추가된 속성
    let db = Firestore.firestore()
    var isSelectArray = [Bool]()
    
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

    // Firestore에 plan 정보 저장
    //MARK: - FireStore Methods
    func saveUserToFirestore(user: User, userId: String) {
        let userRef = db.collection("users").document(userId)
        do {
            try userRef.setData(from: user)
        } catch let error {
            print("Firestore Writing Error: \(error)")
        }
    }
    
    // Firestore에서 사용자 정보 가져오기
    func fetchUserFromFirestore(userId: String, completion: @escaping (User?) -> Void) {
        let userRef = db.collection("users").document(userId)
        userRef.getDocument { (document, error) in
            if let document = document, document.exists {
                do {
                    let user = try document.data(as: User.self)
                    completion(user)
                } catch let error {
                    print("User Decoding Error: \(error)")
                    completion(nil)
                }
            } else {
                print("Firestore에 User이 존재하지 않음.")
                completion(nil)
            }
        }
    }
    
    func initializeSelectArray() {
        isSelectArray = [Bool](repeating: false, count: friends.count)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let navigationBar = self.navigationController?.navigationBar {
            navigationBar.overrideUserInterfaceStyle = .light
        }
        
        saveUserToFirestore(user: UserInfo.shared.user!, userId: String(UserInfo.shared.user!.id))

        // Firestore에서 사용자 정보 가져오기
        fetchUserFromFirestore(userId: String(UserInfo.shared.user!.id)) { [weak self] user in
            guard let self = self else { return }
            if let user = user {
                // Firestore에서 가져온 사용자 정보를 friends 배열에 추가
                self.friends.append(user)
                // isSelectArray 초기화
                self.initializeSelectArray()
                // 테이블 뷰 리로드
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
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
    
    // 약속 공유 함수
    func sharePlan(with friend: inout User) {
        guard let plan = selectedPlan else {
            print("선택된 약속이 없습니다.")
            return
        }

        // 사용자의 sharedPlans에 공유된 약속 추가
        if friend.sharedPlan == nil {
            friend.sharedPlan = []
        }
        friend.sharedPlan?.append(plan)
        
        // Firestore에 공유된 약속 저장
        saveUserToFirestore(user: friend, userId: friend.id)
        
        dismiss(animated: true, completion: nil)
    }

}
