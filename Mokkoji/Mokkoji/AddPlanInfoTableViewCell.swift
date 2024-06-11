//
//  AddPlanInfoTableViewCell.swift
//  Mokkoji
//
//  Created by 박지혜 on 6/11/24.
//

import UIKit

class AddPlanInfoTableViewCell: UITableViewCell {
    
    lazy var titleText: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        return datePicker
    }()
    
    lazy var bodyText: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(titleText)
        addSubview(datePicker)
        addSubview(bodyText)
        
        NSLayoutConstraint.activate([
            titleText.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor),
            titleText.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor),
//            titleText.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor),
            titleText.heightAnchor.constraint(equalToConstant: 50),
            
            datePicker.topAnchor.constraint(equalTo: titleText.bottomAnchor, constant: -8),
            datePicker.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor),
//            datePicker.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor),
            datePicker.heightAnchor.constraint(equalToConstant: 30),
            
            bodyText.topAnchor.constraint(equalTo: datePicker.bottomAnchor, constant: -8),
            bodyText.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor),
//            bodyText.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor),
            bodyText.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor),
            bodyText.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
