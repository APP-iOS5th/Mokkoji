import UIKit
import FirebaseFirestore
import Firebase

class PlanListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let tableView = UITableView()
    let segmentedControl = UISegmentedControl(items: ["나의 약속", "공유 받은 약속"])
    var isEditMode = false // Edit 모드 여부를 추적
    var isSelectArray = [Bool]()
    
    var plans: [Plan] = []
    var sharedPlans: [Plan] = []
    var users: [User] = []
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        self.navigationItem.title = "약속 리스트"
        
        setupNavigationBarAppearance()
        setupSegmentedControl()
        
        // 왼쪽에 Add 버튼 추가
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))
        addButton.tintColor = UIColor(named: "Primary_Color")
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
        
        // isSelectArray 초기화
        initializeSelectArray()
    }
    
    func setupSegmentedControl() {
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(segmentedControlValueChanged(_:)), for: .valueChanged)
        navigationItem.titleView = segmentedControl
    }
    
    func setupNavigationBarAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white // 배경색을 흰색으로 설정
        appearance.titleTextAttributes = [.foregroundColor: UIColor.black] // 타이틀 색상을 검정색으로 설정

        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.tintColor = UIColor(named: "Primary_Color") // 버튼 아이템 색상 설정
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
                print("Firestore에 User가 존재하지 않음.")
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
        self.navigationController?.navigationBar.prefersLargeTitles = false
        self.navigationItem.largeTitleDisplayMode = .always
        
        fetchPlanFromFirestore(userId: UserInfo.shared.user!.id) { [weak self] user in
            guard let self = self else { return }
            if let user = user {
                self.plans = user.plan ?? []
                self.sharedPlans = user.sharedPlan ?? []
                UserInfo.shared.user?.sharedPlan = self.sharedPlans
                
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
    
    // 체크되면 삭제될 메서드
    @objc func doneButtonTapped() {
        var indexesToDeleteFromPlans = [Int]()
        var indexesToDeleteFromSharedPlans = [Int]()
        var plansToDelete = [Plan]()
        var sharedPlansToDelete = [Plan]()
        
        // 선택된 항목을 인덱스에 따라 plans와 sharedPlans에 대해 나누어 처리
        for (index, isSelected) in isSelectArray.enumerated() {
            if isSelected {
                if segmentedControl.selectedSegmentIndex == 0 {
                    indexesToDeleteFromPlans.append(index)
                    plansToDelete.append(plans[index])
                } else {
                    indexesToDeleteFromSharedPlans.append(index)
                    sharedPlansToDelete.append(sharedPlans[index])
                }
            }
        }

        // Firestore에서 plans와 sharedPlans 각각의 삭제 작업 수행
        if segmentedControl.selectedSegmentIndex == 0 {
            deletePlansFromFirestore(plansToDelete)
            for index in indexesToDeleteFromPlans.reversed() {
                plans.remove(at: index)
                isSelectArray.remove(at: index)
            }
        } else {
            deleteSharedPlansFromFirestore(sharedPlansToDelete)
            for index in indexesToDeleteFromSharedPlans.reversed() {
                sharedPlans.remove(at: index)
                isSelectArray.remove(at: index)
            }
        }

        // isSelectArray 초기화
        initializeSelectArray()

        // 테이블 뷰의 데이터 업데이트
        tableView.reloadData()

        // UI 업데이트
        editButtonTapped() // Edit 모드 종료
    }
    
    // Firestore에서 plans 삭제
    func deletePlansFromFirestore(_ plansToDelete: [Plan]) {
        guard let userId = UserInfo.shared.user?.id else { return }
        let userRef = db.collection("users").document(userId)
        
        userRef.updateData([
            "plan": FieldValue.arrayRemove(plansToDelete.map { try! Firestore.Encoder().encode($0) })
        ]) { error in
            if let error = error {
                print("Error removing plans: \(error)")
            } else {
                print("Plans successfully removed!")
            }
        }
    }

    // Firestore에서 sharedPlans 삭제
    func deleteSharedPlansFromFirestore(_ sharedPlansToDelete: [Plan]) {
        guard let userId = UserInfo.shared.user?.id else { return }
        let userRef = db.collection("users").document(userId)
        
        userRef.updateData([
            "sharedPlan": FieldValue.arrayRemove(sharedPlansToDelete.map { try! Firestore.Encoder().encode($0) })
        ]) { error in
            if let error = error {
                print("Error removing shared plans: \(error)")
            } else {
                print("Shared plans successfully removed!")
            }
        }
    }

    // 체크박스 추가
    func setNeedsUpdateConfiguration(_ cell: CustomTableViewCell, at indexPath: IndexPath) {
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
    }
    
    // 체크박스 생성
    @objc func checkBoxTapped(_ sender: UIButton) {
        let row = sender.tag
        isSelectArray[row].toggle()
        let imageName = isSelectArray[row] ? "checkmark.square.fill" : "checkmark.square"
        sender.setImage(UIImage(systemName: imageName), for: .normal)
    }
    
    // 선택한 셀을 tap하면 이동
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if segmentedControl.selectedSegmentIndex == 0 {
            let selectedPlan = plans[indexPath.row]
            let pmDetailViewController = PlanDetailViewController()
            pmDetailViewController.plans = [selectedPlan] // 선택된 계획만 전달
            navigationController?.pushViewController(pmDetailViewController, animated: true)
        } else {
            let selectedSharedPlan = sharedPlans[indexPath.row]
            let sharedDetailViewController = SharedDetailViewController()
            sharedDetailViewController.selectedPlan = selectedSharedPlan // 선택한 공유 약속을 전달
            navigationController?.pushViewController(sharedDetailViewController, animated: true)
        }
    }

    // 섹션 수 설정
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if segmentedControl.selectedSegmentIndex == 0 {
            return plans.count
        } else {
            return sharedPlans.count
        }
    }
    
    // 셀 구성
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomTableViewCell
        
        if segmentedControl.selectedSegmentIndex == 0 {
            let plan = plans[indexPath.row]
            cell.titleLabel.text = plan.title
            cell.dateLabel.text = plan.date
            
            // 사용자 정보가 UserInfo.shared.user에 있으므로 해당 정보를 사용합니다.
            loadImage(from: UserInfo.shared.user?.profileImageUrl) { image in
                DispatchQueue.main.async {
                    cell.profileimage.image = image ?? UIImage(systemName: "person.crop.circle")
                }
            }
        } else {
            let sharedPlan = sharedPlans[indexPath.row]
            cell.titleLabel.text = sharedPlan.title
            cell.dateLabel.text = sharedPlan.date
            
            // 사용자 정보가 UserInfo.shared.user에 있으므로 해당 정보를 사용합니다.
            loadImage(from: UserInfo.shared.user?.profileImageUrl) { image in
                DispatchQueue.main.async {
                    cell.profileimage.image = image ?? UIImage(systemName: "person.crop.circle")
                }
            }
        }
        
        setNeedsUpdateConfiguration(cell, at: indexPath)
        return cell
    }
    
    @objc func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        tableView.reloadData()
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
