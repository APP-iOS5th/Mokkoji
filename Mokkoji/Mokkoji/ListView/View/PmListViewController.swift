//
//  PmListViewController.swift
//  Mokkoji
//
//  Created by 차지용 on 6/10/24.
//

import UIKit

class PmListViewController: UIViewController,UITableView {

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
    }
    
    
    
    
    
    // Add 버튼 클릭 시 실행될 메서드
    @objc func addButtonTapped() {
        print("Add button tapped")
        // 여기에 Add 버튼 클릭 시 실행될 동작을 추가합니다.
    }

    // Edit 버튼 클릭 시 실행될 메서드
    @objc func editButtonTapped() {
        print("Edit button tapped")
        // 여기에 Edit 버튼 클릭 시 실행될 동작을 추가합니다.
    }
}

