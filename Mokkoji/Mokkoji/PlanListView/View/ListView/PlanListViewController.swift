//
//  PlanListViewController.swift
//  Mokkoji
//
//  Created by 박지혜 on 6/11/24.
//

import UIKit

class PlanListViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        self.navigationItem.title = "약속 리스트"
        self.navigationController?.navigationBar.prefersLargeTitles = false
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))
    }
    
    // Add 버튼 클릭 시 실행될 메서드
    @objc func addButtonTapped() {
        print("Add button tapped")
        // 추가뷰로 이동
        let addPlanViewController = AddPlanViewController()
        self.navigationController?.pushViewController(addPlanViewController, animated: true)
    }

}
