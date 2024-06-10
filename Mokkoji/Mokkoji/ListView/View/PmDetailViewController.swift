//
//  PmDetailViewController.swift
//  Mokkoji
//
//  Created by 차지용 on 6/10/24.
//

import UIKit

class PmDetailViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MapViewController의 인스턴스 생성
        let mapViewController = MapViewController(nibName: nil, bundle: nil)
        
        // MapViewController의 뷰를 PmDetailViewController의 서브뷰로 추가
        addChild(mapViewController)
        view.addSubview(mapViewController.view)
        mapViewController.didMove(toParent: self)
        
        // 서브뷰의 크기 및 위치 설정 (예시: 화면 전체에 채우기)
        mapViewController.view.frame = view.bounds
    }
}

