//
//  PmDetailViewCell.swift
//  Mokkoji
//
//  Created by 차지용 on 6/10/24.
//

import UIKit

class PmDetailViewCell: UITableViewCell {

    let titleLabel = UILabel()
    let dateLabel = UILabel()
    let clockImage = UIImageView(image: UIImage(systemName: "clock.fill"))
    let mapContainerView = UIView() // 맵을 담을 컨테이너 뷰
   

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(dateLabel)
        
        clockImage.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(clockImage)
        
        // 맵 컨테이너 뷰 설정
        mapContainerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(mapContainerView)
        
        // 제약 조건 설정
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            
            dateLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            
            clockImage.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            clockImage.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            
            mapContainerView.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 10),
            mapContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            mapContainerView.widthAnchor.constraint(equalToConstant: 200), // 원하는 너비
            mapContainerView.heightAnchor.constraint(equalToConstant: 200), // 원하는 높이
            mapContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10) // 적절한 여백을 주어 맵뷰가 화면 전체를 차지하지 않도록 함
        ])

    }

    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configureMap(mapViewController: MapViewController, mapSize: CGSize) {
        // 기존의 자식 뷰와 관련된 제약 조건 제거
        for subview in mapContainerView.subviews {
            subview.removeFromSuperview()
        }
        
        // 새로운 자식 뷰 추가 및 제약 조건 설정
        mapViewController.view.translatesAutoresizingMaskIntoConstraints = false
        mapContainerView.addSubview(mapViewController.view)
        
        let safeArea = mapContainerView.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            mapViewController.view.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            mapViewController.view.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            mapViewController.view.topAnchor.constraint(equalTo: safeArea.topAnchor),
            mapViewController.view.heightAnchor.constraint(equalToConstant: mapSize.height), // 맵의 원하는 높이
            mapViewController.view.widthAnchor.constraint(equalToConstant: mapSize.width) // 맵의 원하는 너비
        ])
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        print("layoutSubviews called")
        print("mapContainerView frame: \(mapContainerView.frame)")
        mapContainerView.layoutIfNeeded()
    }


}

