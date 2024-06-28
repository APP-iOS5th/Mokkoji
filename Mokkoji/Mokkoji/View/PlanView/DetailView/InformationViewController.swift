//
//  InformationViewController.swift
//  Mokkoji
//
//  Created by 차지용 on 6/11/24.
//

import UIKit
import Firebase

class InformationViewController: UIViewController, UITableViewDataSource,UITableViewDelegate {

    let tableView = UITableView()
    let promissTitle = UILabel()
    var plans: [Plan] = []
    var selectedPlan: Plan? // 선택한 항목을 저장할 변수 추가
    var friendList:[User] = []
    let db = Firestore.firestore()


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
            promissTitle.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            promissTitle.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            
            // tableView 제약조건
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.topAnchor.constraint(equalTo: promissTitle.bottomAnchor, constant: 20),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: sharedBtn.topAnchor, constant: -20),
            
            // sharedBtn 제약조건
            sharedBtn.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            sharedBtn.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            sharedBtn.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            sharedBtn.heightAnchor.constraint(equalToConstant: 50),

        ])
    }
    // Firestore에서 plan 정보 가져오기
    func fetchPlanFromFirestore(userId: String, completion: @escaping (User?) -> Void) {
        let planRef = db.collection("users").document(userId)
        planRef.getDocument { (document, error) in
            if let document = document, document.exists {
                do {
                    let user = try document.data(as: User.self)
                    completion(user)
                } catch let error {
                    print("Plan Decoding Error: \(error)")
                    completion(nil)
                }
            } else {
                print("Firestore에 Plan이 존재하지 않음.")
                completion(nil)
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // 전체 plans 배열에서 mapInfo의 모든 placeName의 수를 합산하여 반환
        return plans.reduce(0) { $0 + $1.mapInfo.count }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PmDetailViewCell", for: indexPath) as! PlanDetailViewCell
        
        // plans 배열을 순회하며 mapInfo 배열의 placeName과 시간을 가져오기 위해 인덱스 계산
        var cumulativeCount = 0
        for plan in plans {
            if indexPath.row < cumulativeCount + plan.mapInfo.count {
                let mapInfoIndex = indexPath.row - cumulativeCount
                let placeName = plan.mapInfo[mapInfoIndex].placeName
                cell.titleLabel.text = plan.title
                cell.bodyLabel.text = plan.body
                
                // 해당 place의 시간 가져오기
                let mapTimeInfo = plan.mapTimeInfo[mapInfoIndex]
                let timeFormatter = DateFormatter()
                timeFormatter.dateFormat = "HH:MM"
                let formattedDate = timeFormatter.string(from: mapTimeInfo)
                cell.timeLabel.text = formattedDate
                
                cell.clockImage.image = UIImage(systemName: "clock.fill")
                cell.placeNameLabel.text = placeName
                
                print("Cell Data:")
                print("Title: \(plan.title)")
                print("Body: \(plan.body)")
                print("Place Name: \(placeName)")
                print("Time: \(formattedDate)")
                break
            }
            cumulativeCount += plan.mapInfo.count
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
