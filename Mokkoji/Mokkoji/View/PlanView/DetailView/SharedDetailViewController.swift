import UIKit
import FirebaseFirestore
import Firebase

class SharedDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let tableView = UITableView()
    let mapViewController = MapViewController()
    var selectedPlan: Plan? // 선택한 항목을 저장할 변수 추가
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
            mapViewController.view.widthAnchor.constraint(equalToConstant: 300),
            mapViewController.view.heightAnchor.constraint(equalToConstant: 300),
            
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
        return selectedPlan != nil ? 1 : 0 // 선택한 계획이 있는 경우에만 1개의 셀을 반환
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PmDetailViewCell", for: indexPath) as! PlanDetailViewCell
        
        if let selectedPlan = selectedPlan {
            cell.titleLabel.text = selectedPlan.title // 선택한 계획의 제목을 표시
            cell.bodyLabel.text = selectedPlan.body // 선택한 계획의 내용을 표시
            
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "HH:mm"
            let formattedDate = timeFormatter.string(from: selectedPlan.time ?? Date())
            cell.timeLabel.text = formattedDate // 선택한 계획의 시간을 표시
            
            cell.clockImage.image = UIImage(systemName: "clock.fill") // 시계 이미지 표시
        }
        
        return cell
    }
}



