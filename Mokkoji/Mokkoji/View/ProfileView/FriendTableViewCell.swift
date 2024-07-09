import UIKit

class FriendTableViewCell: UITableViewCell {
    let userImageView = UIImageView()
    let userNameLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        userImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(userImageView)
        
        userNameLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(userNameLabel)
        
        NSLayoutConstraint.activate([
            userImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            userImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            userImageView.widthAnchor.constraint(equalToConstant: 40),
            userImageView.heightAnchor.constraint(equalToConstant: 40),
            
            userNameLabel.leadingAnchor.constraint(equalTo: userImageView.trailingAnchor, constant: 16),
            userNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            userNameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])

        // 이미지 뷰를 동그랗게 설정
        userImageView.layer.cornerRadius = 20
        userImageView.clipsToBounds = true
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
