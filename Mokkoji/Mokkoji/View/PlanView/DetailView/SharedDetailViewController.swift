import UIKit
import FirebaseFirestore
import Firebase

class SharedDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let tableView = UITableView()
    let mapViewController = MapViewController()
    var selectedPlan: Plan? // 선택한 항목을 저장할 변수 추가
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
        
        // 선택된 약속을 sharPlan에 추가
        if let selectedPlan = selectedPlan {
            sharPlan.append(selectedPlan)
        }
        
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
        // 전체 plans 배열에서 detailTextInfo의 모든 항목 수를 합산하여 반환
        return sharPlan.reduce(0) { $0 + $1.detailTextInfo.count }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PmDetailViewCell", for: indexPath) as! PlanDetailViewCell
        
        // plans 배열을 순회하며 detailTextInfo 배열의 항목을 가져오기 위해 인덱스 계산
        var cumulativeCount = 0
        for plan in sharPlan {
            if indexPath.row < cumulativeCount + plan.detailTextInfo.count {
                let detailTextInfoIndex = indexPath.row - cumulativeCount
                let detailText = plan.detailTextInfo[detailTextInfoIndex]
                cell.detailTextInfoLabel.text = detailText
                
                cell.titleLabel.text = plan.title
                cell.bodyLabel.text = plan.body
                
                // 해당 place의 시간 가져오기 (인덱스 범위 내인지 확인)
                if detailTextInfoIndex < plan.mapTimeInfo.count {
                    let mapTimeInfo = plan.mapTimeInfo[detailTextInfoIndex]
                    let timeFormatter = DateFormatter()
                    timeFormatter.dateFormat = "HH:mm"
                    let formattedDate = timeFormatter.string(from: mapTimeInfo!)
                    cell.timeLabel.text = formattedDate
                } else {
                    cell.timeLabel.text = ""
                }
                
                // placeName 설정 (인덱스 범위 내인지 확인)
                if detailTextInfoIndex < plan.mapInfo.count {
                    let placeName = plan.mapInfo[detailTextInfoIndex].placeName
                    cell.placeNameLabel.text = placeName
                } else {
                    cell.placeNameLabel.text = ""
                }
                
                cell.clockImage.image = UIImage(systemName: "clock.fill")
                break
            }
            cumulativeCount += plan.detailTextInfo.count
        }
        
        return cell
    }
}
