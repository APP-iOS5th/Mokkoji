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
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        
        bodyLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(bodyLabel)
        
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(timeLabel)
        
        clockImage.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(clockImage)

        // 제약 조건 설정
        NSLayoutConstraint.activate([
            // clockImage 설정
            clockImage.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 8),
            clockImage.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            clockImage.widthAnchor.constraint(equalToConstant: 20),
            clockImage.heightAnchor.constraint(equalToConstant: 20),
            clockImage.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -200),
            
            timeLabel.leadingAnchor.constraint(equalTo: clockImage.trailingAnchor, constant: 16),
            timeLabel.topAnchor.constraint(equalTo: clockImage.topAnchor),

            // titleLabel 설정
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),

            // dateLabel 설정
            bodyLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            bodyLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            bodyLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            bodyLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
