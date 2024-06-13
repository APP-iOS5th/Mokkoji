//
//  SharedDetailViewController.swift
//  Mokkoji
//
//  Created by 차지용 on 6/12/24.
//

import UIKit
import FirebaseFirestore
import Firebase
class SharedDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let tableView = UITableView()
    let mapViewController = MapViewController()
    var plans: [Plan] = []
    var selectedPlan: Plan? // 선택한 항목을 저장할 변수 추가
    var user: User!
    var plan: Plan!
    
    let db = Firestore.firestore()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 네비게이션 바 설정
        self.title = "Detail View"
        if let navigationBar = self.navigationController?.navigationBar {
            navigationBar.isTranslucent = false
            navigationBar.barTintColor = .white // 네비게이션 바 배경색 설정
            navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black] // 텍스트 색상 설정
        }
        
        // 기본 뷰 배경색 설정
        view.backgroundColor = .white
        
        // 테이블 뷰 설정
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(PmDetailViewCell.self, forCellReuseIdentifier: "PmDetailViewCell")
        tableView.backgroundColor = .white // 테이블 뷰 배경색 설정
        
        // Add child view controller
        addChild(mapViewController)
        view.addSubview(mapViewController.view)
        mapViewController.didMove(toParent: self)
        
        // 맵 뷰 배경색 설정
        mapViewController.view.backgroundColor = .white
        
        // 뷰 계층 구조에 테이블 뷰 추가
        view.addSubview(tableView)
        
        // Set up constraints for the map view
        mapViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        // 테이블 뷰 제약 조건 설정
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mapViewController.view.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            mapViewController.view.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.9), // 너비를 슈퍼뷰 너비의 90%로 설정
            mapViewController.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mapViewController.view.heightAnchor.constraint(equalToConstant: 300),
            
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: mapViewController.view.bottomAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        plans = [
            Plan(uuid: UUID(), order: 4, title: "회의", body: "Zoom 회의", date: Date().toString(), time: Date(), mapInfo: [], currentLatitude: nil, currentLongitude: nil, participant: nil),
            Plan(uuid: UUID(), order: 5, title: "디너", body: "친구와 저녁 식사", date: Date().toString(), time: Date(), mapInfo: [], currentLatitude: nil, currentLongitude: nil, participant: nil)
         ]
    }
    
    // Firestore에서 plan 정보 가져오기
    func fetchPlanFromFirestore(userId: String, completion: @escaping (Plan?) -> Void) {
        let planRef = db.collection("plans").document(userId)
        planRef.getDocument { (document, error) in
            if let document = document, document.exists {
                do {
                    let plan = try document.data(as: Plan.self)
                    completion(plan)
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
        return plans.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PmDetailViewCell", for: indexPath) as! PmDetailViewCell
        if let sharedPlan = plan {
            cell.titleLabel.text = sharedPlan.title
            cell.bodyLabel.text = sharedPlan.body
            
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "HH:mm"
            let formattedDate = timeFormatter.string(from: sharedPlan.time ?? Date())
            cell.timeLabel.text = formattedDate
            
            cell.clockImage.image = UIImage(systemName: "clock.fill")
        }
        return cell
    }
    
}
