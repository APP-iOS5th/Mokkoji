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
    
    @objc func addButtonTapped() {
        let addPlanViewController = AddPlanViewController()
        self.navigationController?.pushViewController(addPlanViewController, animated: true)
    }

}
