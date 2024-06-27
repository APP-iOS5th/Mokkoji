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
    var mapInfo: MapInfo? // MapInfo 저장 변수 추가
    
    lazy var mainContainer: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 네비게이션 바 설정
        self.title = "상세 약속"
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
        tableView.allowsMultipleSelection = true //테이블 여러개 선택되지 않게해줌
        
        
        // Add child view controller
        addChild(mapViewController)
        view.addSubview(mapViewController.view)
        mapViewController.didMove(toParent: self)
        
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
            
            mapViewController.view.topAnchor.constraint(equalTo: mainContainer.contentLayoutGuide.topAnchor),
            mapViewController.view.leadingAnchor.constraint(equalTo: mainContainer.frameLayoutGuide.leadingAnchor),
            mapViewController.view.trailingAnchor.constraint(equalTo: mainContainer.frameLayoutGuide.trailingAnchor),
            mapViewController.view.widthAnchor.constraint(equalToConstant: 300),
            mapViewController.view.heightAnchor.constraint(equalToConstant: 300),
            
            tableView.leadingAnchor.constraint(equalTo: mainContainer.frameLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: mainContainer.frameLayoutGuide.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: mapViewController.view.bottomAnchor, constant: 8),
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
                break
            }
            cumulativeCount += plan.mapInfo.count
        }
        
        return cell
    }
    
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 선택된 셀의 데이터를 처리할 수 있습니다.
        if indexPath.row < plans.count {
            selectedPlan = plans[indexPath.row]
            
            // InformationViewController 생성
            let informationViewController = InformationViewController()
            
            // 선택한 Plan을 InformationViewController에 전달
            informationViewController.selectedPlan = selectedPlan
            
            // InformationViewController로 이동
            navigationController?.pushViewController(informationViewController, animated: true)
        }
        
        // 선택한 셀의 선택을 해제합니다. (원하는 경우 선택을 유지하려면 이 부분을 제거하세요)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
