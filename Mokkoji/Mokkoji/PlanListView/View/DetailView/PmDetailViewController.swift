import UIKit

class PmDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let tableView = UITableView()
    let mapViewController = MapViewController(nibName: nil, bundle: nil)
    var plans: [Plan] = []
    var selectedPlan: Plan? // 선택한 항목을 저장할 변수 추가
    
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
            Plan(uuid: UUID(), order: 1, title: "시간순삭", body: "판교역", date: Date(), time: Date(), mapInfo: [], currentLatitude: nil, currentLongitude: nil, participant: nil),
            Plan(uuid: UUID(), order: 2, title: "재밌다", body: "카카오", date: Date(), time: Date(), mapInfo: [], currentLatitude: nil, currentLongitude: nil, participant: nil),
            Plan(uuid: UUID(), order: 3, title: "투어", body: "네이버", date: Date(), time: Date(), mapInfo: [], currentLatitude: nil, currentLongitude: nil, participant: nil),
        ]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return plans.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PmDetailViewCell", for: indexPath) as! PmDetailViewCell
        let plan = plans[indexPath.row]
        // titleLabel, dateLabel 및 clockImage 설정
        cell.titleLabel.text = plan.title
        cell.bodyLabel.text = plan.body
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        let formattedDate = timeFormatter.string(from: plan.time)
        cell.timeLabel.text = formattedDate
        
        cell.clockImage.image = UIImage(systemName: "clock.fill")
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