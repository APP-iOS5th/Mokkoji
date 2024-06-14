//
//  PmListViewController.swift
//  Mokkoji
//
//  Created by 차지용 on 6/10/24.
//

import UIKit
import FirebaseFirestore
import Firebase

class PlanListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    let tableView = UITableView()
    var isEditMode = false // Edit 모드 여부를 추적
    var isSelectArray = [Bool]()
    
    var plans: [Plan] = []
   
    
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
//        plans = [
//            Plan(uuid: UUID(), order: 1, title: "시간순삭", body: "판교역", date: Date(), time: Date(), mapInfo: [], currentLatitude: nil, currentLongitude: nil, participant: nil),
//            Plan(uuid: UUID(), order: 2, title: "Lunch", body: "홍대역", date: Date(), time: Date(), mapInfo: [], currentLatitude: nil, currentLongitude: nil, participant: nil),
//            Plan(uuid: UUID(), order: 3, title: "Call", body: "Client call", date: Date(), time: Date(), mapInfo: [], currentLatitude: nil, currentLongitude: nil, participant: nil)
//        ]
//        let sharedPlans = [
//            Plan(uuid: UUID(), order: 4, title: "회의", body: "Zoom 회의", date: Date(), time: Date(), mapInfo: [], currentLatitude: nil, currentLongitude: nil, participant: nil),
//            Plan(uuid: UUID(), order: 5, title: "디너", body: "친구와 저녁 식사", date: Date(), time: Date(), mapInfo: [], currentLatitude: nil, currentLongitude: nil, participant: nil)
//        ]
        
//        UserInfo.shared.user?.plan = plans
//        UserInfo.shared.user?.sharedPlan = sharedPlans
        
        plans = UserInfo.shared.user?.plan ?? []


        // isSelectArray 초기화
        initializeSelectArray()
        //Firestore에 plan 정보 저장

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


    func initializeSelectArray() {
        isSelectArray = [Bool](repeating: false, count: plans.count)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let navigationBar = self.navigationController?.navigationBar {
            navigationBar.overrideUserInterfaceStyle = .light
        }
//        saveUserToFirestore(user: UserInfo.shared.user!, userId: String(UserInfo.shared.user!.id))

        // Firestore에서 계획 정보 가져오기
        fetchPlanFromFirestore(userId: String(UserInfo.shared.user!.id)) { [weak self] user in
            guard let self = self else { return }
            if let user = user {
                // Firestore에서 가져온 계획이 있으면 plans 배열에 추가
                self.plans = user.plan ?? []
                // isSelectArray 초기화
                self.initializeSelectArray()
                // 테이블 뷰 리로드
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }




    // Add 버튼 클릭 시 실행될 메서드
    @objc func addButtonTapped() {
        print("Add button tapped")
        // 추가뷰로 이동
        let addPlanViewController = AddPlanViewController()
        self.navigationController?.pushViewController(addPlanViewController, animated: true)
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
            let selectedSharedPlan = plans[indexPath.row]
            let pmDetailViewController = PlanDetailViewController()
            pmDetailViewController.plans = [selectedSharedPlan] // 선택된 계획만 전달
            navigationController?.pushViewController(pmDetailViewController, animated: true)
        }
        else {
            let selectedSharedPlan = plans[indexPath.row]
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
           
            return UserInfo.shared.user?.sharedPlan?.count ?? 0
        }
    }

    // 셀 구성
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let plan = plans[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomTableViewCell
            cell.titleLabel.text = plan.title
            cell.dateLabel.text = plan.date
            
            // 사용자 정보가 UserInfo.shared.user에 있으므로 해당 정보를 사용합니다.
            loadImage(from: UserInfo.shared.user?.profileImageUrl) { image in
                DispatchQueue.main.async {
                    cell.profileimage.image = image ?? UIImage(systemName: "person.crop.circle")
                }
            }
            setNeedsUpdateConfiguration(cell, at: indexPath)
            return cell
        } else {
            // 공유 받은 약속 셀 구성
            let sharedPlan = plans[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomTableViewCell
            
            cell.titleLabel.text = sharedPlan.title
            cell.dateLabel.text = sharedPlan.date
            
            // 사용자 정보가 UserInfo.shared.user에 있으므로 해당 정보를 사용합니다.
            loadImage(from: UserInfo.shared.user?.profileImageUrl) { image in
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
    
    func loadImage(from url: URL?, completion: @escaping (UIImage?) -> Void) {
        guard let url = url else {
            // URL이 nil인 경우 기본 이미지를 반환합니다.
            completion(UIImage(systemName: "person.crop.circle"))
            return
        }
        // URL이 nil이 아닌 경우에만 데이터 태스크를 시작합니다.
        URLSession.shared.dataTask(with: url) { data, response, error in
            // 이미지 데이터 로딩 후에 에러가 발생하거나 데이터가 nil인 경우를 처리합니다.
            if let error = error {
                print("Error loading image: \(error)")
                completion(UIImage(systemName: "person.crop.circle"))
                return
            }
            guard let data = data, let image = UIImage(data: data) else {
                // 데이터가 nil이거나 이미지 변환에 실패한 경우 기본 이미지를 반환합니다.
                completion(UIImage(systemName: "person.crop.circle"))
                return
            }
            // 이미지 로딩이 성공하면 completion 핸들러를 호출하여 이미지를 반환합니다.
            completion(image)
        }.resume() // 데이터 태스크를 시작합니다.
    }
}
