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
    
    //정규식
    ///@ 앞에 알파벳, 숫자, 특수문자가 포함될 수 있고 @ 뒤에는 알파벳, 숫자, 그리고 . 뒤에는 알파벳 2자리 이상
    let emailPattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
    ///비밀번호 정규식으로, 소문자, 대문자, 숫자 6자리 이상
    let passwordPattern = "^[a-zA-Z0-9]{6,}$"
    var emailValid = false
    var passwordValid = false
    var profileImageValid = false
    var allValid = false
    
    
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
    
    ///회원가입 이름 Label
    private lazy var signUpNameLabel: UILabel = {
        var label = UILabel()
        label.text = "이름"
        label.textColor = .black
        label.font = .systemFont(ofSize: UIFont.smallSystemFontSize)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    ///회원가입 이름
    private lazy var signUpNameTextField: UITextField = {
        var textField = UITextField()
        textField.placeholder = "이름을 입력해 주세요."
        let leftPadding = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: textField.frame.height))
        textField.leftViewMode = .always
        textField.leftView = leftPadding
        textField.backgroundColor = .white
        textField.layer.cornerRadius = 5
        textField.layer.borderColor = UIColor.systemGray4.cgColor
        textField.layer.borderWidth = 1
        textField.keyboardType = .namePhonePad
        textField.autocorrectionType = .no //자동완성 비활성화
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    ///회원가입 이메일
    private lazy var signUpEmailTextField: UITextField = {
        var textField = UITextField()
        textField.placeholder = "example@mokkoji.com"
        let leftPadding = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: textField.frame.height))
        textField.leftViewMode = .always
        textField.leftView = leftPadding
        textField.backgroundColor = .white
        textField.layer.borderColor = UIColor.systemGray4.cgColor
        textField.layer.borderWidth = 1
        textField.layer.cornerRadius = 5
        textField.textContentType = .emailAddress
        textField.keyboardType = .emailAddress
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    ///회원가입 이메일 Label
    private lazy var signUpEmailLabel: UILabel = {
        var label = UILabel()
        label.text = "이메일"
        label.textColor = .black
        label.font = .systemFont(ofSize: UIFont.smallSystemFontSize)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    ///회원가입 비밀번호
    private lazy var signUpPasswordTextField: UITextField = {
        var textField = UITextField()
        textField.placeholder = "영문, 숫자 6자리 이상 입력해 주세요."
        let leftPadding = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: textField.frame.height))
        textField.leftViewMode = .always
        textField.leftView = leftPadding
        textField.layer.borderColor = UIColor.systemGray4.cgColor
        textField.layer.borderWidth = 1
        textField.layer.cornerRadius = 5
        textField.isSecureTextEntry = true
        textField.textContentType = .none
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    ///회원가입 비밀번호 Label
    private lazy var signUpPasswordLabel: UILabel = {
        var label = UILabel()
        label.text = "비밀번호"
        label.textColor = .black
        label.font = .systemFont(ofSize: UIFont.smallSystemFontSize)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    ///회원가입 버튼
    private lazy var signUpButton: UIButton = {
        var button = UIButton()
        button.setTitle("가입하기", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(named: "Primary_Color")
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(signUpButtonTapped), for: .touchUpInside)
        return button
    }()
    
    //MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "회원가입"
        
        self.hideKeyboardWhenTappedAround()
        
        setDelegate()
        
        self.view.backgroundColor = .white
        
        view.addSubviews([
            signUpProfileImage,
            signUpProfileImageSetButton,
            signUpNameTextField,
            signUpNameLabel,
            signUpEmailTextField,
            signUpEmailLabel,
            signUpPasswordTextField,
            signUpPasswordLabel,
            signUpButton
        ])
        
        NSLayoutConstraint.activate([
            
            //signUpProfileImage Constraint
            signUpProfileImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            signUpProfileImage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            signUpProfileImage.widthAnchor.constraint(equalToConstant: 150),
            signUpProfileImage.heightAnchor.constraint(equalToConstant: 150),
            
            
            //signUpProfileImageSetButton Constraint
            signUpProfileImageSetButton.topAnchor.constraint(equalTo: signUpProfileImage.bottomAnchor, constant: -50),
            signUpProfileImageSetButton.trailingAnchor.constraint(equalTo: signUpProfileImage.trailingAnchor, constant:  10),
            signUpProfileImageSetButton.widthAnchor.constraint(equalToConstant: 60),
            signUpProfileImageSetButton.heightAnchor.constraint(equalToConstant: 60),
            
            //signUpNameTextField Constraint
            signUpNameTextField.topAnchor.constraint(equalTo: signUpProfileImageSetButton.bottomAnchor, constant: 50),
            signUpNameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            signUpNameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            signUpNameTextField.heightAnchor.constraint(equalToConstant: 40),
            
            //signUpNameLabel Constraint
            signUpNameLabel.bottomAnchor.constraint(equalTo: signUpNameTextField.topAnchor, constant: -3),
            signUpNameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 25),
            signUpNameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            signUpNameLabel.heightAnchor.constraint(equalToConstant: 20),
            
            //signUpEmailTextField Constraint
            signUpEmailTextField.topAnchor.constraint(equalTo: signUpNameTextField.bottomAnchor, constant: 30),
            signUpEmailTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            signUpEmailTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            signUpEmailTextField.heightAnchor.constraint(equalToConstant: 40),
            
            //signUpEmailLabel Constraint
            signUpEmailLabel.bottomAnchor.constraint(equalTo: signUpEmailTextField.topAnchor, constant: -3),
            signUpEmailLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 25),
            signUpEmailLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            signUpEmailLabel.heightAnchor.constraint(equalToConstant: 20),
            
            //signUpPasswordTextField Constraint
            signUpPasswordTextField.topAnchor.constraint(equalTo: signUpEmailTextField.bottomAnchor, constant: 30),
            signUpPasswordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            signUpPasswordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            signUpPasswordTextField.heightAnchor.constraint(equalToConstant: 40),
            
            //signUpPasswordLabel Constraint
            signUpPasswordLabel.bottomAnchor.constraint(equalTo: signUpPasswordTextField.topAnchor, constant: -3),
            signUpPasswordLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 25),
            signUpPasswordLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            signUpPasswordLabel.heightAnchor.constraint(equalToConstant: 20),
            
            //signUpButton Constraint
            signUpButton.topAnchor.constraint(equalTo: signUpPasswordTextField.bottomAnchor, constant: 50),
            signUpButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            signUpButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            signUpButton.heightAnchor.constraint(equalToConstant: 50),
            
        ])
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
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
        let imagePicker = PHPickerViewController(configuration: configuration)
        imagePicker.delegate = self
        present(imagePicker, animated: true)
    }
    
    @objc func signUpButtonTapped() {

        if profileImageValid == false {
            //TODO: Alert로 프로필 이미지 설정해야한다고
            print("프로필 이미지를 설정 해야합니다.")
        } else if emailValid == false {
            //TODO: Alert로 이메일 정규식이 맞지 않는다고
            print("이메일 형식이 올바르지 않습니다.")
        } else if passwordValid == false {
            //TODO: Alert로 비밀번호 정규식이 맞지 않는다고
            print("비밀번호 형식이 올바르지 않습니다.")
        } else {
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
    }
    
    //MARK: - Keyboard Handling Methods
    
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func keyboardWillShow(_ notification: NSNotification) {
        print("keyboard up")
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            
            let keyboardHeight = keyboardSize.height
            let safeAreaBottomInset = view.safeAreaInsets.bottom
            
            // 키보드 위와 signUpButton 남은 공간
            let signUpButtonBottom = signUpButton.frame.origin.y + signUpButton.frame.size.height
            let spaceAboveKeyboard = view.frame.size.height - keyboardHeight - safeAreaBottomInset
            
            // signUpButton이 키보드 위에 있는지 확인 후, 필요한 만큼 화면 이동
            if signUpButtonBottom > spaceAboveKeyboard {
                view.frame.origin.y = -(signUpButtonBottom - spaceAboveKeyboard + 10)
            }
        }
    }
    
    @objc func keyboardWillHide(_ notification: NSNotification) {
        print("keyboard down")
        if view.frame.origin.y != 0 {
            view.frame.origin.y = 0
        }
    }
    
    //MARK: - 유효성 검사 Methods
    func isValid(text: String, pattern: String) -> Bool {
        let pred = NSPredicate(format: "SELF MATCHES %@", pattern)
        return pred.evaluate(with: text)
    }
    
    func checkEmailValidation() {
        if isValid(text: signUpEmailTextField.text!, pattern: emailPattern) {
            emailValid = true
        } else {
            emailValid = false
        }
    }
    
    func checkPasswordValidation() {
        if isValid(text: signUpPasswordTextField.text!, pattern: passwordPattern) {
            passwordValid = true
        } else {
            passwordValid = false
        }
    }
    
    fileprivate func checkAllValidation() {
        if emailValid && passwordValid {
            print("email, password Valid Success")
            allValid = true
        } else {
            print("email, password Valid Fail")
            allValid = false
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
                    self.signUpProfileImage.layer.cornerRadius = 20
                    self.signUpProfileImage.clipsToBounds = true
                    
                    print("SignUp selected Image: \(selectedImage)")

                }
            }
        }
        self.profileImageValid = true
        picker.dismiss(animated: true, completion: nil)
    }
}


//MARK: - UITextFieldDelegate Methods
extension SignUpViewController: UITextFieldDelegate {
    //TODO: UITextFieldDelegate Method 추가하기..
    func textFieldDidBeginEditing(_ textField: UITextField) {
        //텍스트 필드 강조
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
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.systemGray4.cgColor
        switch textField {
        case signUpEmailTextField:
            checkEmailValidation()
        case signUpPasswordTextField:
            checkPasswordValidation()
        default:
            break
        }
        checkAllValidation()
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        return true
    }
}

//#Preview {
//    let viewController = SignUpViewController()
//    return viewController
//}
