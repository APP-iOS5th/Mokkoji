//
//  PmListViewController.swift
//  Mokkoji
//
//  Created by 차지용 on 6/10/24.
//

import UIKit

class PmListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    let tableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        self.navigationItem.title = "약속 리스트"

        // 왼쪽에 Add
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))
        self.navigationItem.leftBarButtonItem = addButton

        // 오른쪽에 Edit
        let editButton = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editButtonTapped))
        self.navigationItem.rightBarButtonItem = editButton

        // 테이블 뷰 설정
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(CustomTableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.frame = view.bounds
        view.addSubview(tableView)
    }

    // Add 버튼 클릭 시 실행될 메서드
    @objc func addButtonTapped() {
        print("Add button tapped")
        // 여기에 Add 버튼 클릭 시 실행될 동작을 추가합니다.
    }

    // Edit 버튼 클릭 시 실행될 메서드
    @objc func editButtonTapped() {
        print("Edit button tapped")
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            let PmDetailView = PmDetailViewController()
            navigationController?.pushViewController(PmDetailView, animated: true)
        }
    }

    // 섹션 수 설정
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    // 각 섹션의 행 수 설정
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 3 // 첫 번째 섹션의 행 수
        } else {
            return 3 // 두 번째 섹션의 행 수
        }
    }

    // 셀 구성
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomTableViewCell
        cell.titleLabel.text = "title"
        cell.dateLabel.text = "Date"
        cell.profileimage.image
        return cell
    }
    
    

    // 섹션 헤더 타이틀 설정
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "나의 약속"
        } else {
            return "공유 받은 약속"
        }
    }
}

