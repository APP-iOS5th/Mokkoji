import UIKit
import FirebaseFirestore
import Firebase

class PlanDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let tableView = UITableView()
    let mapViewController = MapViewController()
    var plans: [Plan] = []
    var selectedPlan: Plan? // 선택한 항목을 저장할 변수 추가
    var plan: Plan?
    var user: User!
    let db = Firestore.firestore()
    var isSelectArray = [Bool]()
    
    lazy var mainContainer: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
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
        tableView.register(PlanDetailViewCell.self, forCellReuseIdentifier: "PmDetailViewCell")
        tableView.backgroundColor = .white // 테이블 뷰 배경색 설정
        
        // Add child view controller
        addChild(mapViewController)
        view.addSubview(mapViewController.view)
        mapViewController.didMove(toParent: self)
        
        // 맵 뷰 배경색 설정
//        mapViewController.view.backgroundColor = .white
        
        // 뷰 계층 구조에 테이블 뷰 추가
//        view.addSubview(tableView)
        view.addSubview(mainContainer)
        mainContainer.addSubview(mapViewController.view)
        mainContainer.addSubview(tableView)
        
        // Set up constraints for the map view
        mapViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        // 테이블 뷰 제약 조건 설정
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mainContainer.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 20),
            mainContainer.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            mainContainer.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            mainContainer.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            
//            mapViewController.view.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
//            mapViewController.view.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.9), // 너비를 슈퍼뷰 너비의 90%로 설정
            
            mapViewController.view.topAnchor.constraint(equalTo: mainContainer.contentLayoutGuide.topAnchor),
            mapViewController.view.leadingAnchor.constraint(equalTo: mainContainer.frameLayoutGuide.leadingAnchor),
            mapViewController.view.trailingAnchor.constraint(equalTo: mainContainer.frameLayoutGuide.trailingAnchor),
            mapViewController.view.widthAnchor.constraint(equalToConstant: 300),
            mapViewController.view.heightAnchor.constraint(equalToConstant: 300),
            
            tableView.leadingAnchor.constraint(equalTo: mainContainer.frameLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: mainContainer.frameLayoutGuide.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: mapViewController.view.bottomAnchor),
            tableView.bottomAnchor.constraint(equalTo: mainContainer.frameLayoutGuide.bottomAnchor)
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
    
    func initializeSelectArray() {
        isSelectArray = [Bool](repeating: false, count: plans.count)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let navigationBar = self.navigationController?.navigationBar {
            navigationBar.overrideUserInterfaceStyle = .light
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return plans.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PmDetailViewCell", for: indexPath) as! PlanDetailViewCell
        if indexPath.section == 0 {
            // 나의 약속 섹션
            let plan = plans[indexPath.row]
            cell.titleLabel.text = plan.title
            cell.bodyLabel.text = plan.body
            
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "HH:mm"
            let formattedDate = timeFormatter.string(from: plan.time ?? Date())
            cell.timeLabel.text = formattedDate
            
            cell.clockImage.image = UIImage(systemName: "clock.fill")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            selectedPlan = plans[indexPath.row]
            
            // InformationViewController 생성
            let informationViewController = InformationViewController()
            
            // 선택한 Plan을 InformationViewController에 전달
            informationViewController.selectedPlan = selectedPlan
            
            // InformationViewController로 이동
            navigationController?.pushViewController(informationViewController, animated: true)
        }
    }
}
