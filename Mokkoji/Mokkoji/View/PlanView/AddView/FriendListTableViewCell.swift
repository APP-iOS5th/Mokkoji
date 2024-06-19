//
//  FriendListTableViewCell.swift
//  Mokkoji
//
//  Created by 박지혜 on 6/19/24.
//

import UIKit

class FriendListTableViewCell: UITableViewCell {
        
    lazy var profileImage: UIImageView = {
        let profileImage = UIImageView()
        profileImage.frame = CGRect(x: 0, y: 0, width: 50, height: 50) /// 제약조건과 동일하게 지정
        profileImage.layer.cornerRadius = profileImage.frame.height/2 /// 원 만들기
        profileImage.clipsToBounds = true /// 뷰 영역에 따라 자르기
        profileImage.contentMode = .scaleAspectFill /// 비율 유지, 꽉 채우기
        profileImage.translatesAutoresizingMaskIntoConstraints = false
        
        return profileImage
    }()
    
    lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.distribution = .fill
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
    }()
    
    lazy var friendNameLabel: UILabel = {
        let nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        return nameLabel
    }()
    
    lazy var friendEmailLabel: UILabel = {
        let emailLabel = UILabel()
        emailLabel.textColor = .gray
        emailLabel.translatesAutoresizingMaskIntoConstraints = false
        
        return emailLabel
    }()
    
    lazy var checkBox: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "checkmark.circle"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFill
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        stackView.addArrangedSubview(friendNameLabel)
        stackView.addArrangedSubview(friendEmailLabel)
        
        self.contentView.addSubview(profileImage)
        self.contentView.addSubview(stackView)
        self.contentView.addSubview(checkBox)
        
        /// 제약조건 설정
        NSLayoutConstraint.activate([
            profileImage.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 20),
            profileImage.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
            profileImage.widthAnchor.constraint(equalToConstant: 50),
            profileImage.heightAnchor.constraint(equalToConstant: 50),
            
            friendNameLabel.topAnchor.constraint(equalTo: stackView.topAnchor),
            friendEmailLabel.topAnchor.constraint(equalTo: friendNameLabel.bottomAnchor, constant: 5),
            friendEmailLabel.bottomAnchor.constraint(equalTo: stackView.bottomAnchor),
            
            stackView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 10),
            stackView.leadingAnchor.constraint(equalTo: profileImage.trailingAnchor, constant: 10),
            stackView.trailingAnchor.constraint(equalTo: checkBox.leadingAnchor, constant: -10),
            stackView.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
            
            checkBox.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -20),
            checkBox.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
            checkBox.widthAnchor.constraint(equalToConstant: 50),
            checkBox.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: - Methods
    func configure(friendImage: URL, friendName: String, friendEmail: String) {
        loadImage(from: friendImage)
        friendNameLabel.text = friendName
        friendEmailLabel.text = friendEmail
    }
    
    func loadImage(from url: URL) {
        // 이미지 로드를 위한 비동기 URL 세션 사용
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil, let image = UIImage(data: data) else {
                return
            }
            DispatchQueue.main.async {
                self.profileImage.image = image
            }
        }.resume()
    }

}
