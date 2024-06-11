import UIKit

class PmDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    let tableView = UITableView()
    let mapViewController = MapViewController(nibName: nil, bundle: nil)

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(PmDetailViewCell.self, forCellReuseIdentifier: "PmDetailViewCell")
        view.addSubview(tableView)

        // 테이블 뷰 제약 조건 설정
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        // Add child view controller
        addChild(mapViewController)
        view.addSubview(mapViewController.view)
        mapViewController.didMove(toParent: self)

        // Set up constraints for the map view
        mapViewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mapViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapViewController.view.heightAnchor.constraint(equalToConstant: 200) // Set your desired height here
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
