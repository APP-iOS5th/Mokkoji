//
//  PmDetailViewCell.swift
//  Mokkoji
//
//  Created by 차지용 on 6/10/24.
//

import UIKit

class PlanDetailViewCell: UITableViewCell {

    let titleLabel = UILabel()
    let bodyLabel = UILabel()
    let timeLabel = UILabel()
    let clockImage = UIImageView(image: UIImage(systemName: "clock.fill"))
    let placeNameLabel = UILabel()
    let detailTextInfoLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        
        bodyLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(bodyLabel)
        
        placeNameLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(placeNameLabel)
        
        detailTextInfoLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(detailTextInfoLabel)
        
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(timeLabel)
        
        clockImage.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(clockImage)

        // 제약 조건 설정
        NSLayoutConstraint.activate([
            // titleLabel 설정
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),

            // dateLabel 설정
            bodyLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            bodyLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            bodyLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            // placeNameLabel 설정
            placeNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            placeNameLabel.topAnchor.constraint(equalTo: bodyLabel.bottomAnchor, constant: 8),
            placeNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            // detailTextInfoLabel 설정
            detailTextInfoLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            detailTextInfoLabel.topAnchor.constraint(equalTo: placeNameLabel.bottomAnchor, constant: 8),
            detailTextInfoLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            detailTextInfoLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),

            // clockImage 설정
            clockImage.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 8),
            clockImage.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            clockImage.widthAnchor.constraint(equalToConstant: 20),
            clockImage.heightAnchor.constraint(equalToConstant: 20),
            clockImage.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -200),
            
            timeLabel.leadingAnchor.constraint(equalTo: clockImage.trailingAnchor, constant: 16),
            timeLabel.topAnchor.constraint(equalTo: clockImage.topAnchor),
        ])

    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
