//
//  SignUpViewController.swift
//  Mokkoji
//
//  Created by 정종원 on 6/11/24.
//

import UIKit
import PhotosUI

class SignUpViewController: UIViewController {
    
    //MARK: - Properties
    //    var signUpUserInfo = User(id: "", name: "", email: "", profileImageUrl: URL(string: "")!)
    
    //MARK: - UIComponents
    
    ///프로필 이미지
    private lazy var signUpProfileImage: UIImageView = {
        var imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .lightGray
        imageView.layer.cornerRadius = 20
        return imageView
    }()
    ///프로필 이미지 선택 버튼
    private lazy var signUpProfileImageSetButton: UIButton = {
        var configuration = UIButton.Configuration.plain()
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 30)
        configuration.image = UIImage(systemName: "pencil.circle.fill", withConfiguration: imageConfig)
        configuration.baseForegroundColor = UIColor(cgColor: CGColor(red: 10, green: 52, blue: 255, alpha: 1))
        var button = UIButton(configuration: configuration)
        button.clipsToBounds = true
        button.layer.cornerRadius = 30
        button.addTarget(self, action: #selector(signUpProfileImageButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    ///회원가입 이름
    private lazy var signUpNameTextField: UITextField = {
        var textField = UITextField()
        textField.placeholder = "Name"
        let leftPadding = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: textField.frame.height))
        textField.leftViewMode = .always
        textField.leftView = leftPadding
        textField.backgroundColor = .systemGray4
        textField.layer.cornerRadius = 5
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    ///회원가입 이메일
    private lazy var signUpEmailTextField: UITextField = {
        var textField = UITextField()
        textField.placeholder = "Email"
        let leftPadding = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: textField.frame.height))
        textField.leftViewMode = .always
        textField.leftView = leftPadding
        textField.backgroundColor = .systemGray4
        textField.layer.cornerRadius = 5
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    ///회원가입 비밀번호
    private lazy var signUpPasswordTextField: UITextField = {
        var textField = UITextField()
        textField.placeholder = "password"
        let leftPadding = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: textField.frame.height))
        textField.leftViewMode = .always
        textField.leftView = leftPadding
        textField.backgroundColor = .systemGray4
        textField.layer.cornerRadius = 5
        textField.isSecureTextEntry = true
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    ///회원가입 버튼
    private lazy var signUpButton: UIButton = {
        var button = UIButton()
        button.setTitle("로그인", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    //MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        
        view.addSubviews([
            signUpProfileImage,
            signUpProfileImageSetButton,
            signUpNameTextField,
            signUpEmailTextField,
            signUpPasswordTextField,
            signUpButton
        ])
        
        NSLayoutConstraint.activate([
            
            signUpProfileImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            signUpProfileImage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 130),
            signUpProfileImage.widthAnchor.constraint(equalToConstant: 150),
            signUpProfileImage.heightAnchor.constraint(equalToConstant: 150),
            
            
            //signUpProfileImageSetButton Constraint
            signUpProfileImageSetButton.topAnchor.constraint(equalTo: signUpProfileImage.bottomAnchor, constant: -50),
            signUpProfileImageSetButton.trailingAnchor.constraint(equalTo: signUpProfileImage.trailingAnchor, constant:  10),
            signUpProfileImageSetButton.widthAnchor.constraint(equalToConstant: 60),
            signUpProfileImageSetButton.heightAnchor.constraint(equalToConstant: 60),
            
            //signUpNameTextField Constraint
            signUpNameTextField.topAnchor.constraint(equalTo: signUpProfileImageSetButton.bottomAnchor, constant: 20),
            signUpNameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            signUpNameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            signUpNameTextField.heightAnchor.constraint(equalToConstant: 40),
            
            //signUpEmailTextField Constraint
            signUpEmailTextField.topAnchor.constraint(equalTo: signUpNameTextField.bottomAnchor, constant: 20),
            signUpEmailTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            signUpEmailTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            signUpEmailTextField.heightAnchor.constraint(equalToConstant: 40),
            
            //signUpPasswordTextField Constraint
            signUpPasswordTextField.topAnchor.constraint(equalTo: signUpEmailTextField.bottomAnchor, constant: 20),
            signUpPasswordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            signUpPasswordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            signUpPasswordTextField.heightAnchor.constraint(equalToConstant: 40),
            
            //signUpButton Constraint
            signUpButton.topAnchor.constraint(equalTo: signUpPasswordTextField.bottomAnchor, constant: 50),
            signUpButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            signUpButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            signUpButton.heightAnchor.constraint(equalToConstant: 50),
            
        ])
        
    }
    
    //MARK: - Methods
    @objc func signUpProfileImageButtonTapped() {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 1
        configuration.filter = .images
        var imagePicker = PHPickerViewController(configuration: configuration)
        imagePicker.delegate = self
        present(imagePicker, animated: true)
    }
}

//MARK: - PHPickerViewControllerDelegate Methods
extension SignUpViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)
        
        let itemProvider = results.first?.itemProvider
        if let itemProvider = itemProvider,
           itemProvider.canLoadObject(ofClass: UIImage.self) {
            itemProvider.loadObject(ofClass: UIImage.self) { image, error in
                DispatchQueue.main.async {
                    guard let selectedImage = image as? UIImage else { return }
                    //TODO: - newUser객체의 profile에 profile 넣기
                }
            }
        }
    }
}

#Preview {
    let viewController = SignUpViewController()
    return viewController
}
