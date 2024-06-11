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
   

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(dateLabel)
        
        clockImage.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(clockImage)

        // 제약 조건 설정
        NSLayoutConstraint.activate([
            clockImage.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -200),
            clockImage.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            clockImage.widthAnchor.constraint(equalToConstant: 40),
            clockImage.heightAnchor.constraint(equalToConstant: 40),
            
            // titleLabel 설정
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: clockImage.leadingAnchor, constant: -8),
            
            // dateLabel 설정
            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            dateLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            dateLabel.trailingAnchor.constraint(equalTo: clockImage.leadingAnchor, constant: -8),
            dateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])



    }

    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }



}
