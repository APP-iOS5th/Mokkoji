//
//  PmListViewController.swift
//  Mokkoji
//
//  Created by 차지용 on 6/10/24.
//

import UIKit
import FirebaseFirestore
import Firebase

class PmListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    let tableView = UITableView()
    var isEditMode = false // Edit 모드 여부를 추적
    var isSelectArray = [Bool]()
    
    var plans: [Plan] = []
    var user: User!
    var plan: Plan?
    var user2: User!
    
    let db = Firestore.firestore()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        
        self.navigationItem.title = "약속 리스트"
        
        // 왼쪽에 Add 버튼 추가
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))
        self.navigationItem.leftBarButtonItem = addButton

        // 오른쪽에 Edit 버튼 추가
        let editButton = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editButtonTapped))
        self.navigationItem.rightBarButtonItem = editButton

        // 테이블 뷰 설정
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(CustomTableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.frame = view.bounds
        view.addSubview(tableView)

        // 임시 데이터
        plans = [
            Plan(uuid: UUID(), order: 1, title: "시간순삭", body: "만교역", date: Date(), time: Date(), mapInfo: [], currentLatitude: nil, currentLongitude: nil, participant: nil),
            Plan(uuid: UUID(), order: 2, title: "Lunch", body: "Team lunch", date: Date(), time: Date(), mapInfo: [], currentLatitude: nil, currentLongitude: nil, participant: nil),
            Plan(uuid: UUID(), order: 3, title: "Call", body: "Client call", date: Date(), time: Date(), mapInfo: [], currentLatitude: nil, currentLongitude: nil, participant: nil)
        ]
        let sharedPlans = [
            Plan(uuid: UUID(), order: 4, title: "회의", body: "Zoom 회의", date: Date(), time: Date(), mapInfo: [], currentLatitude: nil, currentLongitude: nil, participant: nil),
            Plan(uuid: UUID(), order: 5, title: "디너", body: "친구와 저녁 식사", date: Date(), time: Date(), mapInfo: [], currentLatitude: nil, currentLongitude: nil, participant: nil)
        ]
        
        user = User(id: 1, name: "홍길동", email: "hong@example.com", profileImageUrl: URL(string: "https://lh3.googleusercontent.com/a/ACg8ocKKJBq7bA6ijBEJIsYa2wz-5JCYj-x0BxeAkll8wvI0L64D1ooi=s320")!, plan: plans, sharedPlan: sharedPlans, friendList: nil)

        // isSelectArray 초기화
        initializeSelectArray()
        //Firestore에 plan 정보 저장
        if let firstPlan = user.plan?.first {
            savePlanToFirestore(plan: firstPlan, planId: firstPlan.uuid.uuidString)
        }
    }
    
    func savePlanToFirestore(plan: Plan, planId: String) {
        let planRef = db.collection("plans").document(planId)
        do {
            try planRef.setData(from: plan, encoder: Firestore.Encoder())
        } catch let error {
            print("Firestore Writing Error: \(error)")
        }
    }




    
    // Firestore에서 plan 정보 가져오기
    func fetchPlanFromFirestore(planId: String, completion: @escaping (Plan?) -> Void) {
        let planRef = db.collection("plans").document(planId)
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


    func initializeSelectArray() {
        isSelectArray = [Bool](repeating: false, count: plans.count)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let navigationBar = self.navigationController?.navigationBar {
            navigationBar.overrideUserInterfaceStyle = .light
        }
    }



    // Add 버튼 클릭 시 실행될 메서드
    @objc func addButtonTapped() {
        print("Add button tapped")
        
         let addPlanViewController = AddPlanViewController()
         navigationController?.pushViewController(addPlanViewController, animated: true)
    }

    // Edit 버튼 클릭 시 실행될 메서드
    @objc func editButtonTapped() {
        isEditMode.toggle()
        if isEditMode {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTapped))
        } else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editButtonTapped))
        }
        tableView.reloadData()
    }
    
    //체크되면 삭제될 메서드
    @objc func doneButtonTapped() {
        var indexesToDelete = [Int]() // 삭제할 인덱스 배열
        
        // 선택된 항목 삭제
        for (index, isSelected) in isSelectArray.enumerated() {
            if isSelected {
                indexesToDelete.append(index)
            }
        }
        
        // 선택된 항목 삭제
        for index in indexesToDelete.reversed() {
            plans.remove(at: index)
            isSelectArray.remove(at: index)
            let indexPath = IndexPath(row: index, section: 0)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        
        // isSelectArray 초기화
        initializeSelectArray()
        
        // 테이블 뷰의 데이터 업데이트
        tableView.reloadData()
        
        // UI 업데이트
        editButtonTapped() // Edit 모드 종료
    }
    
    //체크박스 추가
    func setNeedsUpdateConfiguration(_ cell: CustomTableViewCell, at indexPath: IndexPath) {
        if indexPath.section == 0 {
            if isEditMode {
                let checkBox = UIButton(type: .custom)
                let imageName = isSelectArray[indexPath.row] ? "checkmark.square.fill" : "checkmark.square"
                checkBox.setImage(UIImage(systemName: imageName), for: .normal)
                checkBox.addTarget(self, action: #selector(checkBoxTapped(_:)), for: .touchUpInside)
                checkBox.tag = indexPath.row
                
                // accessoryView의 frame을 설정하여 셀의 accessoryView로 추가
                checkBox.frame = CGRect(x: 0, y: 0, width: 20, height: 20) // 적절한 크기 및 위치를 설정하세요
                cell.accessoryView = checkBox
            } else {
                cell.accessoryView = nil
            }
        } else {
            cell.accessoryView = nil
        }
    }

    //체크박스 생성
    @objc func checkBoxTapped(_ sender: UIButton) {
        let row = sender.tag
        isSelectArray[row].toggle()
        let imageName = isSelectArray[row] ? "checkmark.square.fill" : "checkmark.square"
        sender.setImage(UIImage(systemName: imageName), for: .normal)
    }
    
    //선택한 셀을 tap하면 이동
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            let selectedPlan = user.plan?[indexPath.row]
            let pmDetailViewController = PmDetailViewController()
            pmDetailViewController.plans = [selectedPlan].compactMap { $0 }
            navigationController?.pushViewController(pmDetailViewController, animated: true)
        }
        else {
            let selectedSharedPlan = user.sharedPlan?[indexPath.row]
            let sharedDetailViewController = SharedDetailViewController()
            sharedDetailViewController.plan = selectedSharedPlan // 선택한 약속만 포함하는 속성으로 설정
            navigationController?.pushViewController(sharedDetailViewController, animated: true)
        }

    }

    // 섹션 수 설정
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return plans.count
        } else {
           
            return user.sharedPlan?.count ?? 0
        }
    }

    // 셀 구성
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let plan = plans[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomTableViewCell
            cell.titleLabel.text = plan.title
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let formattedDate = dateFormatter.string(from: plan.date)
            cell.dateLabel.text = formattedDate
            
            loadImage(from: user.profileImageUrl) { image in
                DispatchQueue.main.async {
                    cell.profileimage.image = image ?? UIImage(systemName: "person.crop.circle")
                }
            }
            setNeedsUpdateConfiguration(cell, at: indexPath)
            return cell
        } else {
            // 공유 받은 약속 셀 구성
            let sharedPlan = user.sharedPlan![indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomTableViewCell
            
            cell.titleLabel.text = sharedPlan.title
        
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let formattedDate = dateFormatter.string(from: sharedPlan.date)
            cell.dateLabel.text = formattedDate
            
            loadImage(from: user.profileImageUrl) { image in
                DispatchQueue.main.async {
                    cell.profileimage.image = image ?? UIImage(systemName: "person.crop.circle")
                }
            }
            setNeedsUpdateConfiguration(cell, at: indexPath)
            return cell
        }
    }


    // 섹션 헤더 타이틀 설정
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "나의 약속"
        } else {
            return "공유 받은 약속"
        }
    }
    
    func loadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        // URLSession의 shared 인스턴스를 사용하여 데이터 태스크를 만듭니다.
        URLSession.shared.dataTask(with: url) { data, response, error in
            // 데이터, 에러 확인 후 이미지 변환
            guard let data = data, error == nil, let image = UIImage(data: data) else {
                // 에러가 있거나 데이터가 없거나 이미지 변환이 실패하면 nil을 반환합니다.
                completion(nil)
                return
            }
            // 이미지 변환이 성공하면 completion 핸들러를 호출하여 이미지를 반환합니다.
            completion(image)
        }.resume() // 데이터 태스크를 시작합니다.
    }

}
