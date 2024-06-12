//
//  PlaceListTableViewCell.swift
//  Mokkoji
//
//  Created by 박지혜 on 6/12/24.
//

import UIKit

class PlaceListTableViewCell: UITableViewCell {
    
    lazy var numberIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .black
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()
    
    lazy var placeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    lazy var timePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .time
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        
        return datePicker
    }()
    
    lazy var spacerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
    }()
    
    lazy var detailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "상세 내용을 입력하세요."
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        return textField
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        stackView.addArrangedSubview(numberIcon)
        stackView.addArrangedSubview(placeLabel)
        stackView.addArrangedSubview(timePicker)

        self.contentView.addSubview(stackView)
        self.contentView.addSubview(detailTextField)
        
        NSLayoutConstraint.activate([
            numberIcon.widthAnchor.constraint(equalToConstant: 30),
            numberIcon.heightAnchor.constraint(equalToConstant: 30),
            
            stackView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -10),
            
            detailTextField.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 10),
            detailTextField.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
            detailTextField.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 20),
            detailTextField.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -10)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(number: UIImage?, placeInfo: String) {
        numberIcon.image = number
        placeLabel.text = placeInfo
    }

}
