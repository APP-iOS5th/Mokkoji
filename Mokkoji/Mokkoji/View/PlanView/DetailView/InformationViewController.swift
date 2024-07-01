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
    let mapViewController = MapViewController()
    var plans: [Plan] = []
    var selectedPlan: Plan? // 선택한 항목을 저장할 변수 추가
    var plan: Plan?
    var user: User!
    let db = Firestore.firestore()
    var isSelectArray = [Bool]()
    var mapInfo: MapInfo? // MapInfo 저장 변수 추가
    
    let promissTitle = UILabel()
    var friendList:[User] = []


    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        self.title = "공유"
        promissTitle.text = "공유"
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
        sharedBtn.backgroundColor = .systemBlue
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
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -300),
            //sharedBtn 제약조건
            sharedBtn.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            sharedBtn.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: -20),
            sharedBtn.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -100),
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

    // numberOfRowsInSection에서 selectedPlan을 사용하도록 수정
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // selectedPlan이 nil이 아닌지 확인하고, mapInfo 배열의 모든 placeName의 수를 반환
        return selectedPlan?.mapInfo.count ?? 0
    }

    // cellForRowAt에서 selectedPlan을 사용하도록 수정
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PmDetailViewCell", for: indexPath) as! PlanDetailViewCell

        // selectedPlan의 mapInfo 배열에서 placeName과 시간을 가져옴
        if let selectedPlan = selectedPlan {
            let placeName = selectedPlan.mapInfo[indexPath.row].placeName
            cell.titleLabel.text = selectedPlan.title
            cell.bodyLabel.text = selectedPlan.body

            // 해당 place의 시간 가져오기
            let mapTimeInfo = selectedPlan.mapTimeInfo[indexPath.row]
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "HH:MM"
            let formattedDate = timeFormatter.string(from: mapTimeInfo!)
            cell.timeLabel.text = formattedDate
            
            // detailTextInfo 배열을 적절하게 처리하여 문자열로 병합
//            let detailTextInfo = selectedPlan.detailTextInfo.joined(separator: ", ")
//            cell.detailTextInfoLabel.text = detailTextInfo

            cell.clockImage.image = UIImage(systemName: "clock.fill")
            cell.placeNameLabel.text = placeName
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
