//
//  AddPlanViewController.swift
//  Mokkoji
//
//  Created by 박지혜 on 6/11/24.
//

import UIKit

class AddPlanViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        self.navigationItem.title = "약속 추가"

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        /// 큰 타이틀 설정
        self.navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        /// PlanListView의 title은 inline으로 유지
        self.navigationController?.navigationBar.prefersLargeTitles = false
    }
    

    
}
