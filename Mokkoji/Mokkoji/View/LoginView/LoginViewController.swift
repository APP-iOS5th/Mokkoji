//
//  ViewController.swift
//  Mokkoji
//
//  Created by 정종원 on 6/4/24.
//


import UIKit

import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import GoogleSignIn
import KakaoSDKCommon
import KakaoSDKAuth
import KakaoSDKUser


extension UIView {
    func addSubviews(_ views: [UIView]) {
        for view in views {
            self.addSubview(view)
        }
    }
}

class LoginViewController: UIViewController {
    
    //MARK: - Properties
    let db = Firestore.firestore()  //firestore
    
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
    ///로그인 로고
    private lazy var logoImage: UIImageView = {
        var imageView = UIImageView(image: UIImage(named: "MokkojiLogo"))
        imageView.sizeToFit()
        imageView.backgroundColor = .white
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    ///로그인 이메일
    private lazy var emailTextField: UITextField = {
        var textField = UITextField()
        textField.placeholder = "이메일을 입력해 주세요."
        let leftPadding = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: textField.frame.height))
        textField.leftViewMode = .always
        textField.leftView = leftPadding
        textField.backgroundColor = .white
        textField.layer.borderColor = UIColor.systemGray4.cgColor
        textField.layer.borderWidth = 1
        textField.layer.cornerRadius = 5
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    ///로그인 이메일 Label
    private lazy var emailLabel: UILabel = {
        var label = UILabel()
        label.text = "이메일"
        label.textColor = .black
        label.font = .systemFont(ofSize: UIFont.smallSystemFontSize)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    ///로그인 비밀번호
    private lazy var passwordTextField: UITextField = {
        var textField = UITextField()
        textField.placeholder = "비밀번호를 입력해 주세요."
        let leftPadding = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: textField.frame.height))
        textField.leftViewMode = .always
        textField.leftView = leftPadding
        textField.backgroundColor = .white
        textField.layer.borderColor = UIColor.systemGray4.cgColor
        textField.layer.borderWidth = 1
        textField.layer.cornerRadius = 5
        textField.isSecureTextEntry = true
        textField.textContentType = .none
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    ///로그인 비밀번호 Label
    private lazy var passwordLabel: UILabel = {
        var label = UILabel()
        label.text = "비밀번호"
        label.textColor = .black
        label.font = .systemFont(ofSize: UIFont.smallSystemFontSize)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    //비밀번호 전체 삭제 버튼
    private lazy var clearAllPasswordButton: UIButton = {
        var button = UIButton()
        button.setImage(UIImage(systemName: "x.circle.fill"), for: .normal)
        button.tintColor = .black
        button.backgroundColor = .systemGray4
        button.isHidden = true
        button.addTarget(self, action: #selector(clearAllPasswordButtonTapped), for: .touchUpInside)
        button.layer.zPosition = 1000
        button.layer.cornerRadius = 15
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    ///비밀번호 표시 토글 버튼
    private lazy var hiddenToggleButton: UIButton = {
        var button = UIButton()
        button.setImage(UIImage(systemName: "eye.slash.fill"), for: .normal)
        button.tintColor = .black
        button.backgroundColor = .systemGray4
        button.isHidden = true
        button.addTarget(self, action: #selector(hiddenToggleButtonTapped), for: .touchUpInside)
        button.layer.zPosition = 1000
        button.layer.cornerRadius = 15
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    ///로그인 버튼
    private lazy var loginButton: UIButton = {
        var button = UIButton()
        button.setTitle("로그인", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.backgroundColor = UIColor(named: "Primary_Color")
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        return button
    }()
    
    ///아이디 찾기 버튼
    private lazy var searchEmailButton: UIButton = {
        var button = UIButton()
        button.setTitle("아이디 찾기", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        button.backgroundColor = .white
        button.setTitleColor(.lightGray, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    ///비밀번호 찾기 버튼
    private lazy var searchPasswordButton: UIButton = {
        var button = UIButton()
        button.setTitle("비밀번호 찾기", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        button.backgroundColor = .white
        button.setTitleColor(.lightGray, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    ///signUpLabel
    private lazy var signUpLabel: UILabel = {
        var label = UILabel()
        label.text = "계정이 없으신가요?"
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = .lightGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    ///회원가입 버튼
    private lazy var signUpButton: UIButton = {
        var button = UIButton()
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        let title = "회원가입"
        let attributedTitle = NSMutableAttributedString(string: title)
        attributedTitle.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: title.count))
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.backgroundColor = .white
        button.setTitleColor(.lightGray, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(signUpButtonTapped), for: .touchUpInside)
        return button
    }()
    
    ///Sign Up With SNS 선
    private lazy var signUpWithSNSLeadingLine: UIView = {
        var signUpWithSNSLeadingLine = UIView()
        signUpWithSNSLeadingLine.backgroundColor = .gray
        signUpWithSNSLeadingLine.translatesAutoresizingMaskIntoConstraints = false
        return signUpWithSNSLeadingLine
    }()
    
    ///Sign Up With SNS 선
    private lazy var signUpWithSNSTrailingLine: UIView = {
        var signUpWithSNSTrailingLine = UIView()
        signUpWithSNSTrailingLine.backgroundColor = .gray
        signUpWithSNSTrailingLine.translatesAutoresizingMaskIntoConstraints = false
        return signUpWithSNSTrailingLine
    }()
    
    ///Sign Up With SNS Label
    private lazy var signInWithSNSLabel: UILabel = {
        var label = UILabel()
        label.text = "Sign Up With SNS"
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    ///카카오 로그인 버튼
    private lazy var kakaoLoginButton: UIButton = {
        var button = UIButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 50, weight: .light)
        let image = UIImage(named: "Property 1=Default")
        button.setImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(kakaoLoginButtonTapped), for: .touchUpInside)
        return button
    }()
    
    ///애플 로그인 버튼
    private lazy var appleLoginButton: UIButton = {
        var button = UIButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 50, weight: .light)
        let image = UIImage(named: "Sign in with Apple - Logo Only - Black - Circle")
        button.setImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.imageView?.contentMode = .scaleAspectFill
        button.addTarget(self, action: #selector(appleLoginButtonTapped), for: .touchUpInside)
        return button
    }()
    
    ///구글 로그인 버튼
    private lazy var googleLoginButton: UIButton = {
        var button = UIButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        button.setImage(UIImage(named: "ios_light_rd_na"), for: .normal)
        button.backgroundColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(googleLoginButtonTapped), for: .touchUpInside)
        return button
    }()
    
    ///아이디 찾기, 비밀버튼 찾기 StackView
    private lazy var searchStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = 20
        return stackView
    }()
    
    ///회원가입 StackView
    private lazy var signUpStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = 10
        return stackView
    }()
    
    ///Sign Up With SNS StackView
    private lazy var signUpSNSLabelStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalCentering
        return stackView
    }()
    
    ///SNS Buttons StackView
    private lazy var snsButtonsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        return stackView
    }()
    
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround()
        
        view.backgroundColor = .white
        
        setDelegate()
        
        view.addSubviews([logoImage,
                          emailTextField,
                          emailLabel,
                          passwordTextField,
                          passwordLabel,
                          clearAllPasswordButton,
                          hiddenToggleButton,
                          loginButton,
                          searchStackView,
                          signUpStackView,
                          signUpSNSLabelStackView,
                          snsButtonsStackView
                         ])
        
        let searchStackViewLeftSpacer = UIView()
        let signInStackViewLeftSpacer = UIView()
        let snsLeftSpacer = UIView()
        let snsRightSpacer = UIView()
        searchStackView.addArrangedSubview(searchStackViewLeftSpacer)
        searchStackView.addArrangedSubview(searchEmailButton)
        searchStackView.addArrangedSubview(searchPasswordButton)
        signUpStackView.addArrangedSubview(signInStackViewLeftSpacer)
        signUpStackView.addArrangedSubview(signUpLabel)
        signUpStackView.addArrangedSubview(signUpButton)
        signUpSNSLabelStackView.addArrangedSubview(signUpWithSNSLeadingLine)
        signUpSNSLabelStackView.addArrangedSubview(signInWithSNSLabel)
        signUpSNSLabelStackView.addArrangedSubview(signUpWithSNSTrailingLine)
        snsButtonsStackView.addArrangedSubview(snsLeftSpacer)
        snsButtonsStackView.addArrangedSubview(kakaoLoginButton)
        snsButtonsStackView.addArrangedSubview(appleLoginButton)
        snsButtonsStackView.addArrangedSubview(googleLoginButton)
        snsButtonsStackView.addArrangedSubview(snsRightSpacer)

        
        NSLayoutConstraint.activate([
            // logoImage Constraints
            logoImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            logoImage.widthAnchor.constraint(equalToConstant: 180),
            logoImage.heightAnchor.constraint(equalToConstant: 200),
            
            // emailTextField Constraints
            emailTextField.topAnchor.constraint(equalTo: logoImage.bottomAnchor, constant: 50),
            emailTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            emailTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            emailTextField.heightAnchor.constraint(equalToConstant: 40),
            
            //emailLabel Constraint
            emailLabel.bottomAnchor.constraint(equalTo: emailTextField.topAnchor, constant: -3),
            emailLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 25),
            emailLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            emailLabel.heightAnchor.constraint(equalToConstant: 20),
            
            // passwordTextField Constraints
            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 30),
            passwordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            passwordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            passwordTextField.heightAnchor.constraint(equalToConstant: 40),
            
            //passwordLabel Constraint
            passwordLabel.bottomAnchor.constraint(equalTo: passwordTextField.topAnchor, constant: -3),
            passwordLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 25),
            passwordLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            passwordLabel.heightAnchor.constraint(equalToConstant: 20),
            
            // clearAllPasswordButton Constraints
            clearAllPasswordButton.topAnchor.constraint(equalTo: passwordTextField.topAnchor, constant: 6.5),
            clearAllPasswordButton.trailingAnchor.constraint(equalTo: passwordTextField.trailingAnchor, constant: -5),
            clearAllPasswordButton.widthAnchor.constraint(equalToConstant: 25),
            clearAllPasswordButton.heightAnchor.constraint(equalToConstant: 25),
            
            // hiddenToggleButton Constraints
            hiddenToggleButton.topAnchor.constraint(equalTo: passwordTextField.topAnchor, constant: 6.5),
            hiddenToggleButton.trailingAnchor.constraint(equalTo: clearAllPasswordButton.leadingAnchor, constant: -10),
            hiddenToggleButton.widthAnchor.constraint(equalToConstant: 25),
            hiddenToggleButton.heightAnchor.constraint(equalToConstant: 25),
            
            // loginButton Constraints
            loginButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 30),
            loginButton.heightAnchor.constraint(equalToConstant: 50),
            loginButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            loginButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // searchStackView Constraints
            searchStackView.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 30),
            searchStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            searchStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // signUpStackView Constraints
            signUpStackView.topAnchor.constraint(equalTo: searchStackView.bottomAnchor, constant: 5),
            signUpStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            signUpStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // signUpSNSLabelStackView Constraints
            signUpWithSNSLeadingLine.widthAnchor.constraint(equalToConstant: 100),
            signUpWithSNSLeadingLine.heightAnchor.constraint(equalToConstant: 2),
            signUpWithSNSTrailingLine.widthAnchor.constraint(equalToConstant: 100),
            signUpWithSNSTrailingLine.heightAnchor.constraint(equalToConstant: 2),
            signUpSNSLabelStackView.topAnchor.constraint(equalTo: signUpStackView.bottomAnchor, constant: 30),
            signUpSNSLabelStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            signUpSNSLabelStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            //snsButtonsStackView Constraints
            snsButtonsStackView.topAnchor.constraint(equalTo: signUpSNSLabelStackView.bottomAnchor, constant: 20),
            snsButtonsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            snsButtonsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    //MARK: - Methods
    func setDelegate() {
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    func loginSuccess() {
        guard let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate else { return }
        let tabBarController = sceneDelegate.createTabBarController()
        sceneDelegate.changeRootViewController(tabBarController, animated: true)
    }
    
    @objc func clearAllPasswordButtonTapped() {
        passwordTextField.text = ""
        
        let isPasswordTextFieldEmpty = passwordTextField.text?.isEmpty ?? true
        clearAllPasswordButton.isHidden = isPasswordTextFieldEmpty
        hiddenToggleButton.isHidden = isPasswordTextFieldEmpty
    }
    
    @objc func hiddenToggleButtonTapped() {
        passwordTextField.isSecureTextEntry.toggle()
        
        if passwordTextField.isSecureTextEntry {
            hiddenToggleButton.setImage(UIImage(systemName: "eye.slash.fill"), for: .normal)
        } else {
            hiddenToggleButton.setImage(UIImage(systemName: "eye.fill"), for: .normal)
        }
    }
    
    @objc func signUpButtonTapped() {
        let signUpViewController = SignUpViewController()
        self.navigationController?.pushViewController(signUpViewController, animated: true)
    }
    
    @objc func loginButtonTapped() {
        if let email = emailTextField.text,
           let password = passwordTextField.text {
            Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
                guard let self = self else { return }
                if let error = error {
                    // 에러가 났다면 여기서 처리 ...
                    print("Email Login Error: \(error.localizedDescription)")
                } else {
                    // 로그인에 성공했다면 여기서 처리...
                    fetchUserFromFirestore(userId: password) { user in
                        if let user = user {
                            UserInfo.shared.user = user
                            print("이미 사용자가 존재하는 경우 currentUser 정보 : \(String(describing: UserInfo.shared.user))")
                            //탭바뷰 이동
                            self.loginSuccess()
                            
                        } else {
                            print("User 데이터가 없습니다. ")
                        }
                    }
                    
                }
            }
        }
    }
    
    //MARK: - Keyboard Handling Methods
    
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        emailTextField.layer.borderColor = UIColor.systemGray4.cgColor
        emailTextField.layer.borderWidth = 1
        passwordTextField.layer.borderColor = UIColor.systemGray4.cgColor
        passwordTextField.layer.borderWidth = 1

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
    
    //MARK: - Kakao Login/out Methods
    
    func kakaoSetUserInfo() {
        UserApi.shared.me {(user, error) in
            if let error = error {
                print("setUserInfo Error: \(error.localizedDescription)")
            } else {
                print("setUserInfo nickname: \(user?.kakaoAccount?.profile?.nickname ?? "no nickname")")
                print("setUserInfo email: \(user?.kakaoAccount?.email ?? "no email")")
                print("setUserInfo profileImageUrl: \(String(describing: user?.kakaoAccount?.profile?.profileImageUrl))")
                UserInfo.shared.user?.id =  String((user?.id)!)
                
                //TODO: - fetchSignInMethods deprecated, 이메일로 확인하는것은 보안에 문제가됨.
                // Firebase에 사용자 등록 전에 이미 가입된 사용자인지 확인
                Auth.auth().fetchSignInMethods(forEmail: user?.kakaoAccount?.email ?? "") { signInMethods, error in
                    if let error = error {
                        print("Error checking email duplication: \(error.localizedDescription)")
                        return
                    }
                    if signInMethods != nil {
                        // 이미 사용자가 존재하는 경우 로그인 시도
                        Auth.auth().signIn(withEmail: (user?.kakaoAccount?.email)!,
                                           password: "\(String(describing: user?.id))"
                        ) { authResult, error in
                            if let error = error {
                                print("FB: 이미 사용자가 존재하는 경우 로그인 시도 signin failed error: \(error.localizedDescription)")
                            } else {
                                print("FB: 이미 사용자가 존재하는 경우 로그인 시도 signin success")
                                self.fetchUserFromFirestore(userId: String((user?.id)!)) { user in
                                    if let user = user {
                                        UserInfo.shared.user = user
                                        print("이미 사용자가 존재하는 경우 currentUser 정보 : \(String(describing: UserInfo.shared.user))")
                                        //탭바뷰 이동
                                        self.loginSuccess()
                                        
                                    } else {
                                        print("User 데이터가 없습니다. ")
                                    }
                                }
                            }
                        }
                    } else {
                        // 새로운 사용자 생성
                        Auth.auth().createUser(withEmail: (user?.kakaoAccount?.email)!,
                                               password: "\(String(describing: user?.id))"
                        ) { authResult, error in
                            if let error = error as NSError?, error.code == AuthErrorCode.emailAlreadyInUse.rawValue {
                                // 이메일이 이미 사용 중일 때, 로그인 시도
                                Auth.auth().signIn(withEmail: (user?.kakaoAccount?.email)!,
                                                   password: "\(String(describing: user?.id))"
                                ) { authResult, error in
                                    if let error = error {
                                        print("FB: 이메일이 이미 사용 중일 때, 로그인 시도 signin failed error: \(error.localizedDescription)")
                                    } else {
                                        print("FB: 이메일이 이미 사용 중일 때, 로그인 시도 signin success")
                                        self.fetchUserFromFirestore(userId: String((user?.id)!)) { user in
                                            if let user = user {
                                                UserInfo.shared.user = user
                                                print("fetch 이후 currentUser 정보 : \(String(describing: UserInfo.shared.user))")
                                                //다음뷰 표시
                                                self.loginSuccess()
                                            } else {
                                                print("User 데이터가 없습니다. ")
                                            }
                                        }
                                    }
                                }
                            } else if let error = error {
                                print("FB: 이메일이 사용중이지 않을때 signup failed error: \(error.localizedDescription)")
                            } else {
                                print("FB: 이메일이 사용중이지 않을때 signup success")
                                //사용자 정보 저장
                                if let nickname = user?.kakaoAccount?.profile?.nickname,
                                   let email = user?.kakaoAccount?.email,
                                   let profileImageUrl = user?.kakaoAccount?.profile?.profileImageUrl,
                                   let userId = user?.id {
                                    let user = User(id: String(userId), name: nickname, email: email, profileImageUrl: profileImageUrl)
                                    UserInfo.shared.user = user
                                    
                                    print("이메일이 사용중이지 않을때 사용자 정보 저장: \(String(describing: UserInfo.shared.user))")
                                    
                                    // Firestore에 사용자 정보 저장
                                    self.saveUserToFirestore(user: UserInfo.shared.user!, userId: String(UserInfo.shared.user!.id))
                                    //다음뷰 표시
                                    self.loginSuccess()
                                }
                            }
                        }
                    }
                }
            }
            
        }
    }
    
    @objc func kakaoLoginButtonTapped() {
        print("Kakao Login Button Tapped")
        // 카카오 토큰이 존재한다면
        if AuthApi.hasToken() {
            UserApi.shared.accessTokenInfo { accessTokenInfo, error in
                if let error = error {
                    print("DEBUG: 카카오톡 토큰 가져오기 에러 \(error.localizedDescription)")
                    self.kakaoLogin()
                } else {
                    // 토큰 유효성 체크 성공 (필요 시 토큰 갱신됨)
                    print("토큰이 있음: \(String(describing: accessTokenInfo))")
                    self.kakaoSetUserInfo()
                }
            }
        } else {
            // 토큰이 없는 상태 로그인 필요
            self.kakaoLogin()
            print("토큰이 없는 상태")
        }
    }
    
    func kakaoLogin() {
        if UserApi.isKakaoTalkLoginAvailable() { //카카오톡 앱이 있는경우 loginWithKakaoTalk
            UserApi.shared.loginWithKakaoTalk { (oauthToken, error) in
                if let error = error {
                    print("KakaoTalk Login Error: \(error.localizedDescription)")
                } else {
                    print("loginWithKakaoTalk() success.")
                    self.kakaoSetUserInfo()
                }
            }
        } else { //카카오톡이 설치되어 있지 않은 경우 웹으로 연결 loginWithKakaoAccount
            UserApi.shared.loginWithKakaoAccount { (oauthToken, error) in
                if let error = error {
                    print("KakaoTalk Web Login Error: \(error.localizedDescription)")
                } else {
                    print("loginWithKakaoAccount() success.")
                    self.kakaoSetUserInfo()
                }
            }
        }
    }
    
    // MARK: - 로그아웃 버튼 기능 
    @objc func kakaoLogoutButtonTapped() {
        //kakaoLogout
        UserApi.shared.logout{(error) in
            if let error = error {
                print(error)
            } else {
                print("kakao logout success")
            }
        }
        
        //firebase logout
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            print("firebase logout success")
        } catch let signOutError as NSError {
            print("Error signing out: \(signOutError)")
        }
    }
    
    //MARK: - Google Login/out Methods
    func googleSetUserInfo(_ userID: String, _ userName: String, _ userEmail: String, _ userProfileURL: URL) {
        Auth.auth().fetchSignInMethods(forEmail: userEmail) { signInMethods, error in
            if let error = error {
                print("Error checking email duplication: \(error.localizedDescription)")
                return
            }
            if signInMethods != nil {
                // 이미 사용자가 존재하는 경우 로그인 시도
                Auth.auth().signIn(withEmail: userEmail,
                                   password: userID
                ) { authResult, error in
                    if let error = error {
                        print("FB: 이미 사용자가 존재하는 경우 로그인 시도 signin failed error: \(error.localizedDescription)")
                    } else {
                        print("FB: 이미 사용자가 존재하는 경우 로그인 시도 signin success")
                        self.fetchUserFromFirestore(userId: userID) { user in
                            if let user = user {
                                UserInfo.shared.user = user
                                print("이미 사용자가 존재하는 경우 currentUser 정보 : \(String(describing: UserInfo.shared.user))")
                                //탭바뷰 표시
                                self.loginSuccess()
                                
                            } else {
                                print("User 데이터가 없습니다. ")
                            }
                        }
                    }
                }
            } else {
                // 새로운 사용자 생성
                Auth.auth().createUser(withEmail: userEmail, password: userID) { authResult, error in
                    if let error = error as! NSError?, error.code == AuthErrorCode.emailAlreadyInUse.rawValue {
                        // 이메일이 이미 사용 중일 때, 로그인 시도
                        Auth.auth().signIn(withEmail: userEmail, password: userID) { authResult, error in
                            if let error = error {
                                print("이메일이 이미 사용 중일 때, 로그인 시도 실패: \(error.localizedDescription)")
                            } else {
                                print("이메일이 이미 사용 중일 때, 로그인 시도 성공")
                                self.fetchUserFromFirestore(userId: userID) { user in
                                    if let user = user {
                                        UserInfo.shared.user = user
                                        print("fetch 이후 currentUser 정보: \(String(describing: UserInfo.shared.user))")
                                        //탭바뷰 표시
                                        self.loginSuccess()
                                    } else {
                                        print("User 데이터가 없습니다.")
                                    }
                                }
                            }
                        }
                    } else if let error = error {
                        print("이메일이 사용 중이지 않을 때, 회원가입 실패: \(error.localizedDescription)")
                    } else {
                        print("이메일이 사용 중이지 않을 때, 회원가입 성공")
                        
                        // 사용자 정보 저장
                        let newUser = User(id: userID, name: userName, email: userEmail, profileImageUrl: userProfileURL)
                        UserInfo.shared.user = newUser
                        
                        print("이메일이 사용 중이지 않을 때, 사용자 정보 저장: \(String(describing: UserInfo.shared.user))")
                        
                        // Firestore에 사용자 정보 저장
                        self.saveUserToFirestore(user: newUser, userId: userID)
                        //탭바뷰 표시
                        self.loginSuccess()
                    }
                }
            }
        }
    }
    
    @objc func googleLoginButtonTapped() {
        print("구글 로그인 버튼 tapped")
        // 구글 인증
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        // Start the sign in flow!
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { result, error in
            guard error == nil else { return }
            guard let user = result?.user, let idToken = user.idToken?.tokenString else { return }
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: user.accessToken.tokenString)
            print("Google Login Success User: \(user.userID ?? "")")
            print("Google Login Success User: \(user.profile?.name ?? "")")
            print("Google Login Success User: \(user.profile?.email ?? "")")
            print("Google Login Success User: \(String(describing: user.profile?.imageURL(withDimension: 320)))")
            guard let userID = user.userID else { return }
            guard let userName = user.profile?.name else { return }
            guard let userEmail = user.profile?.email else { return }
            guard let userProfileURL = user.profile?.imageURL(withDimension: 320) else { return }
            //사용자 정보 저장
            self.googleSetUserInfo(userID, userName, userEmail, userProfileURL)
        }
    }
    
    //MARK: - Apple Login Methods
    @objc func appleLoginButtonTapped() {
        //TODO: - 애플 로그인 구현
        loginSuccess()
    }
    
    //MARK: - FireStore Methods
    func saveUserToFirestore(user: User, userId: String) {
        let userRef = db.collection("users").document(userId)
        do {
            try userRef.setData(from: user)
        } catch let error {
            print("Firestore Writing Error: \(error)")
        }
    }
    
    func fetchUserFromFirestore(userId: String, completion: @escaping (User?) -> Void) {
        let userRef = db.collection("users").document(userId)
        userRef.getDocument { (document, error) in
            if let document = document, document.exists {
                do {
                    let user = try document.data(as: User.self)
                    completion(user)
                } catch let error {
                    print("User Decoding Error: \(error)")
                    completion(nil)
                }
            } else {
                print("Firestore에 User가 존재하지 않음.")
                completion(nil)
            }
        }
    }
}

//MARK: - TextField Delegate Methods
extension LoginViewController: UITextFieldDelegate {
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if textField == passwordTextField {
            if let text = textField.text, text.isEmpty {
                clearAllPasswordButton.isHidden = true
                hiddenToggleButton.isHidden = true
            } else {
                clearAllPasswordButton.isHidden = false
                hiddenToggleButton.isHidden = false
            }
        }
    }
    
    //텍스트 필드 강조
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == emailTextField {
            emailTextField.layer.borderColor = UIColor.black.cgColor
            emailTextField.layer.borderWidth = 1
        } else if textField == passwordTextField {
            passwordTextField.layer.borderColor = UIColor.black.cgColor
            passwordTextField.layer.borderWidth = 1
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.systemGray4.cgColor
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
