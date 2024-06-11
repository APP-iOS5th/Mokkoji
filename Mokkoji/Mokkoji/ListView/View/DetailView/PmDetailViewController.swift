//
//  PmDetailViewController.swift
//  Mokkoji
//
//  Created by 차지용 on 6/10/24.
//

import UIKit

class PmDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    let tableView = UITableView()

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
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PmDetailViewCell", for: indexPath) as! PmDetailViewCell
            
            // 첫 번째 셀에만 맵 뷰 추가
            let mapViewController = MapViewController(nibName: nil, bundle: nil)
            self.addChild(mapViewController)
            cell.configureMap(mapViewController: mapViewController) // 원하는 맵의 크기를 전달
            mapViewController.didMove(toParent: self)
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PmDetailViewCell", for: indexPath) as! PmDetailViewCell
            
            // titleLabel, dateLabel 및 clockImage 설정
            cell.titleLabel.text = "title \(indexPath.row)"
            cell.dateLabel.text = "Date \(indexPath.row)"
            cell.clockImage.image = UIImage(systemName: "clock.fill")
            
            // 맵 컨테이너 뷰 숨기기
            cell.mapContainerView.isHidden = true
            
            return cell
        }
    }


    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 250 // 대략적인 높이
    }

}


