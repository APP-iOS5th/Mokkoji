import UIKit

class PmDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    let tableView = UITableView()
    let mapViewController = MapViewController(nibName: nil, bundle: nil)

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
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PmDetailViewCell", for: indexPath) as! PmDetailViewCell
        
        // titleLabel, dateLabel 및 clockImage 설정
        cell.titleLabel.text = "title \(indexPath.row)"
        cell.dateLabel.text = "Date \(indexPath.row)"
        cell.clockImage.image = UIImage(systemName: "clock.fill")
        return cell
    }
}
