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
    
    lazy var bodyText: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(titleText)
        addSubview(datePicker)
        addSubview(bodyText)
        
        NSLayoutConstraint.activate([
            titleText.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            titleText.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            titleText.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            
            datePicker.topAnchor.constraint(equalTo: titleText.bottomAnchor, constant: 8),
            datePicker.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            datePicker.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            
            bodyText.topAnchor.constraint(equalTo: datePicker.bottomAnchor, constant: 8),
            bodyText.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            bodyText.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 뷰에 데이터 연결


}
