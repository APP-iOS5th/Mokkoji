//
//  InformationViewController.swift
//  Mokkoji
//
//  Created by 차지용 on 6/11/24.
//

import UIKit

class InformationViewController: UIViewController, UITableViewDataSource,UITableViewDelegate {

    let tableView = UITableView()
    let promissTitle = UILabel()
    var plans: [Plan] = []
    var selectedPlan: Plan? // 선택한 항목을 저장할 변수 추가
    var currentUser: User? //현재 사용자 추가


    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        
        promissTitle.text = "약속"
        promissTitle.font = UIFont.boldSystemFont(ofSize: 40)
        promissTitle.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(promissTitle)
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(PmDetailViewCell.self, forCellReuseIdentifier: "PmDetailViewCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        let sharedBtn = UIButton()
        sharedBtn.setTitle("공유", for: .normal)
        sharedBtn.addTarget(self, action: #selector(sharedFuntion), for: .touchUpInside)
        sharedBtn.frame = CGRect(x: 0, y: 0, width: 70, height: 50)
        sharedBtn.layer.cornerRadius = 8
        sharedBtn.translatesAutoresizingMaskIntoConstraints = false
        sharedBtn.backgroundColor = .systemBlue // 예시로 빨간색 배경 사용
        view.addSubview(sharedBtn)
        
        NSLayoutConstraint.activate([
            //promissTitle 제약조건
            promissTitle.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            promissTitle.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            promissTitle.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 8),
            
            //tableView 제약조건
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.topAnchor.constraint(equalTo: promissTitle.bottomAnchor, constant: 20),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            //sharedBtn 제약조건
            sharedBtn.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            sharedBtn.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: -20),
            sharedBtn.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -400),
            sharedBtn.heightAnchor.constraint(equalToConstant: 50),

        ])
        plans = [
            Plan(uuid: UUID(), order: 1, title: "시간순삭", body: "판교역", date: Date(), time: Date(), mapInfo: [], currentLatitude: nil, currentLongitude: nil, participant: nil),
            Plan(uuid: UUID(), order: 2, title: "재밌다", body: "카카오", date: Date(), time: Date(), mapInfo: [], currentLatitude: nil, currentLongitude: nil, participant: nil),
            Plan(uuid: UUID(), order: 3, title: "투어", body: "네이버", date: Date(), time: Date(), mapInfo: [], currentLatitude: nil, currentLongitude: nil, participant: nil),
        ]
        let friend1 = User(id: 1, name: "친구 1", email: "friend1@example.com", profileImageUrl: URL(string: "http://example.com/image1")!, plan: nil, friendList: nil)
        let friend2 = User(id: 2, name: "친구 2", email: "friend2@example.com", profileImageUrl: URL(string: "http://example.com/image2")!, plan: nil, friendList: nil)
        let friend3 = User(id: 3, name: "친구 3", email: "friend3@example.com", profileImageUrl: URL(string: "http://example.com/image3")!, plan: nil, friendList: nil)

        currentUser = User(id: 0, name: "현재 사용자", email: "current@example.com", profileImageUrl: URL(string: "http://example.com/image")!, plan: nil, friendList: [friend1, friend2, friend3])

    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PmDetailViewCell", for: indexPath) as! PmDetailViewCell
        
        // selectedPlan을 사용하여 데이터 출력
        if let plan = selectedPlan {
            // titleLabel, bodyLabel 및 timeLabel 설정
            cell.titleLabel.text = plan.title
            cell.bodyLabel.text = plan.body
            
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "HH:mm"
            let formattedDate = timeFormatter.string(from: plan.time)
            cell.timeLabel.text = formattedDate
            
            cell.clockImage.image = UIImage(systemName: "clock.fill")
        }
        
        return cell
    }


    
    //공유 메소드
    @objc func sharedFuntion() {
        print("공유")
        guard let friendList = currentUser?.friendList else{ return }
        
        let friendListV = InfoFriendViewController()
        friendListV.friends = friendList
        friendListV.selectedPlan = selectedPlan
        present(friendListV, animated: true, completion: nil)
        
    }

}
