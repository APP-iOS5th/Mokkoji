import UIKit
import FirebaseFirestore
import Firebase

class SharedDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let tableView = UITableView()
    let mapViewController = PreviewMapViewController(selectedPlaces: [])
    var selectedPlan: Plan? // 선택한 항목을 저장할 변수 추가
    var sharPlan: [Plan] = []
    let db = Firestore.firestore()
    let contentView = UIView()

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
        tableView.allowsMultipleSelection = true //테이블 여러개 선택되지 않게해줌
        
        // Add child view controller
        addChild(mapViewController)
        mapViewController.didMove(toParent: self)
        
        // ScrollView와 contentView 설정
        view.addSubview(mainContainer)
        mainContainer.addSubview(contentView)
        contentView.addSubview(tableView)
        contentView.addSubview(mapViewController.view)
        
        // Set up constraints for the scroll view
        mainContainer.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            mainContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mainContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            mainContainer.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            mainContainer.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            
            contentView.topAnchor.constraint(equalTo: mainContainer.contentLayoutGuide.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: mainContainer.contentLayoutGuide.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: mainContainer.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: mainContainer.contentLayoutGuide.trailingAnchor),
            contentView.widthAnchor.constraint(equalTo: mainContainer.widthAnchor),
        ])

        // 테이블 뷰와 맵 뷰 제약 조건 설정
        tableView.translatesAutoresizingMaskIntoConstraints = false
        mapViewController.view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: contentView.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            tableView.heightAnchor.constraint(equalToConstant: 380),

            mapViewController.view.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 8),
            mapViewController.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            mapViewController.view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            mapViewController.view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            mapViewController.view.heightAnchor.constraint(equalToConstant: 500),
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
