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
    
    // TODO: - 글씨 길이 조정 방안 고르기
    lazy var placeLabel: UILabel = {
        let label = UILabel()
//        label.numberOfLines = 0 /// 무제한 줄 설정
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5 /// 최소 축소 비율 설정
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
            numberIcon.widthAnchor.constraint(equalToConstant: 25),
            numberIcon.heightAnchor.constraint(equalToConstant: 25),
            
            stackView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -10),
            
            detailTextField.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 10),
            detailTextField.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -20),
            detailTextField.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 20),
            detailTextField.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -10)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 기본 시간을 00:00으로 설정하는 함수
    func getDefaultDate() {
        var components = DateComponents()
        /// 연,월,일은 임의로 설정
        components.year = 2000
        components.month = 1
        components.day = 1
        components.hour = 0
        components.minute = 0
        self.timePicker.date = Calendar.current.date(from: components) ?? Date()
    }
    
    func configure(number: UIImage?, placeInfo: String) {
        numberIcon.image = number
        placeLabel.text = placeInfo
    }

}
