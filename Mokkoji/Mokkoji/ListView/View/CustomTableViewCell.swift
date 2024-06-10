//
//  CustomTableViewCell.swift
//  Mokkoji
//
//  Created by 차지용 on 6/10/24.
//

import UIKit

class CustomTableViewCell: UITableViewCell {
    let titleLabel = UILabel()
    let dateLabel = UILabel()
    let profileimage = UIImageView(image: UIImage(systemName: "person.circle.fill"))

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(dateLabel)
        
        profileimage.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(profileimage)
        
        
        
        
        // 제약 조건 설정
        NSLayoutConstraint.activate([
            // iconImageView 설정
            profileimage.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -200),
            profileimage.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            profileimage.widthAnchor.constraint(equalToConstant: 40),
            profileimage.heightAnchor.constraint(equalToConstant: 40),
            
            // titleLabel 설정
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: profileimage.leadingAnchor, constant: -8),
            
            // dateLabel 설정
            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            dateLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            dateLabel.trailingAnchor.constraint(equalTo: profileimage.leadingAnchor, constant: -8),
            dateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
