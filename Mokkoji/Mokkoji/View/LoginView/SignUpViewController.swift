//
//  SignUpViewController.swift
//  Mokkoji
//
//  Created by 정종원 on 6/11/24.
//

import UIKit
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import FirebaseStorage
import PhotosUI

class SignUpViewController: UIViewController {
    
    //MARK: - Properties
    let db = Firestore.firestore()  //firestore
    var user = User(id: UUID().uuidString,
                    name: "",
                    email: "",
                    profileImageUrl: URL(string: "https://picsum.photos/200/300")!)
    
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
        button.setTitle("회원가입", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(signUpButtonTapped), for: .touchUpInside)
        return button
    }()
    
    //MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setDelegate()
        
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
    
    func setDelegate() {
        signUpNameTextField.delegate = self
        signUpEmailTextField.delegate = self
        signUpPasswordTextField.delegate = self
    }
    
    @objc func signUpProfileImageButtonTapped() {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 1
        configuration.filter = .images
        var imagePicker = PHPickerViewController(configuration: configuration)
        imagePicker.delegate = self
        present(imagePicker, animated: true)
    }
    
    @objc func signUpButtonTapped() {
        //TODO: 이메일 정규식 추가, 비밀번호6자, 프로필사진 필수지정  -> 3개 만족해야 회원가입 버튼활성화
        guard let name = self.signUpNameTextField.text else { return }
        guard let email = self.signUpEmailTextField.text else { return }
        guard let password = self.signUpPasswordTextField.text else { return }
        guard let selectedImage = self.signUpProfileImage.image else { return }
        self.user.name = name
        self.user.email = email
        self.user.id = password
        
        
        
        self.uploadImage(image: selectedImage, pathRoot: self.user.id) { url in
            if let url = url {
                self.user.profileImageUrl = url
                
                //유저 프로필 사진 파이어 스토어에 올라간 url 사용하여 사용자 회원가입
                self.createUser(email, password)
            }
        }
    }
    
    //MARK: - FireStore Methods
    func createUser(_ email: String, _ passwrod: String) {
        Auth.auth().createUser(withEmail: email, password: passwrod) {result,error in
            if let error = error {
                print(error)
            }
            
            if let result = result {
                print(result)
            }
            print("FB: Success Create user \(self.user)")
        }
        //Firestore에 저장
        self.saveUserToFirestore(user: self.user, userId: self.user.id)
        self.navigationController?.popViewController(animated: true)
    }
    
    func saveUserToFirestore(user: User, userId: String) {
        let userRef = db.collection("users").document(userId)
        do {
            try userRef.setData(from: user)
        } catch let error {
            print("Firestore Writing Error: \(error)")
        }
    }
    
    //MARK: - Firebase Storage Methods
    //TODO: - Firebase 관련 메소드 FirebaseManger 파일로 묶기.
    //https://firebase.google.com/docs/storage/ios/start?hl=ko
    //https://ios-development.tistory.com/769
    
    ///Firebase Storage에 업로드
    func uploadImage(image: UIImage, pathRoot: String, completion: @escaping (URL?) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.4) else { return }
        let metaData = StorageMetadata()
        metaData.contentType = "image.jpeg"
        
        let imageName = UUID().uuidString + String(Date().timeIntervalSince1970)
        
        let firebaseReference = Storage.storage().reference().child("\(imageName)")
        firebaseReference.putData(imageData, metadata: metaData) { metaData, error in
            firebaseReference.downloadURL { url, _ in
                completion(url)
            }
        }
    }
    
}

//MARK: - PHPickerViewControllerDelegate Methods
extension SignUpViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        let itemProvider = results.first?.itemProvider
        if let itemProvider = itemProvider,
           itemProvider.canLoadObject(ofClass: UIImage.self) {
            itemProvider.loadObject(ofClass: UIImage.self) { image, error in
                DispatchQueue.main.async {
                    guard let selectedImage = image as? UIImage else { return }
                    self.signUpProfileImage.image = selectedImage
                    
                    print("SignUp selected Image: \(selectedImage)")

                }
            }
        }
        picker.dismiss(animated: true, completion: nil)
    }
}


//MARK: - UITextFieldDelegate Methods
extension SignUpViewController: UITextFieldDelegate {
    //TODO: UITextFieldDelegate Method 추가하기.. 
    //    func textFieldDidChangeSelection(_ textField: UITextField) {
    //        if textField == passwordTextField {
    //            if let text = textField.text, text.isEmpty {
    //                clearAllPasswordButton.isHidden = true
    //                hiddenToggleButton.isHidden = true
    //            } else {
    //                clearAllPasswordButton.isHidden = false
    //                hiddenToggleButton.isHidden = false
    //            }
    //        }
    //    }
    
    //텍스트 필드 강조
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == signUpNameTextField {
            signUpNameTextField.layer.borderColor = UIColor.black.cgColor
            signUpNameTextField.layer.borderWidth = 1
        } else if textField == signUpEmailTextField {
            signUpEmailTextField.layer.borderColor = UIColor.black.cgColor
            signUpEmailTextField.layer.borderWidth = 1
        } else {
            signUpPasswordTextField.layer.borderColor = UIColor.black.cgColor
            signUpPasswordTextField.layer.borderWidth = 1
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.layer.borderWidth = 0
        textField.layer.borderColor = .none
    }
}

#Preview {
    let viewController = SignUpViewController()
    return viewController
}
