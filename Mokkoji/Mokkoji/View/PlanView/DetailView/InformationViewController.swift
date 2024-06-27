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
    var friendList:[User] = []


    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        self.title = "공유"
        promissTitle.text = "상세 약속"
        promissTitle.font = UIFont.boldSystemFont(ofSize: 30)
        promissTitle.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(promissTitle)
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(PlanDetailViewCell.self, forCellReuseIdentifier: "PmDetailViewCell")
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
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PmDetailViewCell", for: indexPath) as! PlanDetailViewCell
        
        let plan = plans[indexPath.row]
        cell.titleLabel.text = plan.title
        cell.bodyLabel.text = plan.body
        
        // 특정 날짜를 선택 (예: 첫 번째 날짜)
        if let mapTimeInfo = plan.mapTimeInfo.first {
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "HH:mm"
            let formattedDate = timeFormatter.string(from: mapTimeInfo)
            cell.timeLabel.text = formattedDate
        } else {
            cell.timeLabel.text = "시간 정보 없음"
        }
        
        cell.clockImage.image = UIImage(systemName: "clock.fill")
        
        // mapInfo 배열에서 placeName을 가져와서 출력
        if indexPath.section == 0 {
            if plan.mapInfo.count > 0 { // 배열에 요소가 있는지 확인
                let placeName = plan.mapInfo[indexPath.row].placeName
                cell.placeNameLabel.text = placeName
            }
        }
        
        return cell
    }
    //공유 메소드
    @objc func sharedFuntion() {
        print("공유")
        let friendListV = InfoFriendViewController()
        friendListV.friends = friendList
        friendListV.selectedPlan = selectedPlan
        present(friendListV, animated: true, completion: nil)
    }
}
