import UIKit
import FirebaseFirestore
import Firebase

class SharedDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let tableView = UITableView()
    let mapViewController = MapViewController()
    var selectedPlan: Plan? // 선택한 항목을 저장할 변수 추가
    var selectedPlans: Plan!
    var sharPlan: [Plan] = []
    let db = Firestore.firestore()
    
    lazy var mainContainer: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 네비게이션 바 설정
        self.title = "공유"
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
        
        // 뷰 계층 구조에 테이블 뷰 추가
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
            mapViewController.view.heightAnchor.constraint(equalToConstant: 400), // 맵 뷰 높이 설정
            
            tableView.leadingAnchor.constraint(equalTo: mainContainer.frameLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: mainContainer.frameLayoutGuide.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: mapViewController.view.bottomAnchor, constant: 8),
            tableView.bottomAnchor.constraint(equalTo: mainContainer.frameLayoutGuide.bottomAnchor)
        ])

        
        // 테이블 뷰 리로드
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let navigationBar = self.navigationController?.navigationBar {
            navigationBar.overrideUserInterfaceStyle = .light
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // 전체 plans 배열에서 mapInfo의 모든 placeName의 수를 합산하여 반환
        return sharPlan.reduce(0) { $0 + $1.mapInfo.count }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PmDetailViewCell", for: indexPath) as! PlanDetailViewCell
        
        // plans 배열을 순회하며 mapInfo 배열의 placeName과 시간을 가져오기 위해 인덱스 계산
        var cumulativeCount = 0
        for plan in sharPlan {
            if indexPath.row < cumulativeCount + plan.mapInfo.count {
                let mapInfoIndex = indexPath.row - cumulativeCount
                let placeName = plan.mapInfo[mapInfoIndex].placeName
                cell.titleLabel.text = plan.title
                cell.bodyLabel.text = plan.body
                
                let detailTextInfo = plan.detailTextInfo.joined(separator: ", ")
                cell.detailTextInfoLabel.text = detailTextInfo
                
                // 해당 place의 시간 가져오기
                let mapTimeInfo = plan.mapTimeInfo[mapInfoIndex]
                let timeFormatter = DateFormatter()
                timeFormatter.dateFormat = "HH:MM"
                let formattedDate = timeFormatter.string(from: mapTimeInfo!)
                cell.timeLabel.text = formattedDate
                
                cell.clockImage.image = UIImage(systemName: "clock.fill")
                cell.placeNameLabel.text = placeName
                break
            }
            cumulativeCount += plan.mapInfo.count
        }
        
        return cell
    }
}
