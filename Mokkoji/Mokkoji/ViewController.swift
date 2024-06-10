//
//  ViewController.swift
//  Mokkoji
//
//  Created by 정종원 on 6/4/24.
//

import UIKit
import KakaoSDKCommon
import KakaoSDKAuth
import KakaoSDKUser
import FirebaseAuth
import FirebaseFirestore

extension UIView {
    func addSubviews(_ views: [UIView]) {
        for view in views {
            self.addSubview(view)
        }
    }
}

class ViewController: UIViewController {

    //MARK: - Properties
    let db = Firestore.firestore()  //firestore
    
    private lazy var logoImage: UIImageView = {
        var logoImage = UIImageView(image: UIImage(systemName: "hand.point.up.left.and.text.fill"))
        logoImage.backgroundColor = .lightGray
        logoImage.translatesAutoresizingMaskIntoConstraints = false
        return logoImage
    }()
    
    private lazy var emailTextField: UITextField = {
        var emailTextField = UITextField()
        emailTextField.placeholder = "Email"
        emailTextField.translatesAutoresizingMaskIntoConstraints = false
        return emailTextField
    }()
    
    private lazy var passwordTextField: UITextField = {
        var passwordTextField = UITextField()
        passwordTextField.placeholder = "password"
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        return passwordTextField
    }()
    
    private lazy var loginButton: UIButton = {
        var loginButton = UIButton()
        loginButton.setTitle("로그인", for: .normal)
        loginButton.setTitleColor(.black, for: .normal)
        loginButton.layer.cornerRadius = 10
        loginButton.layer.borderWidth = 1
        loginButton.layer.borderColor = UIColor.lightGray.cgColor
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        return loginButton
    }()
    
    private lazy var searchEmailButton: UIButton = {
        var searchEmail = UIButton()
        searchEmail.setTitle("아이디 찾기", for: .normal)
        searchEmail.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        searchEmail.backgroundColor = .white
        searchEmail.setTitleColor(.lightGray, for: .normal)
        searchEmail.translatesAutoresizingMaskIntoConstraints = false
        return searchEmail
    }()
    
    private lazy var searchPasswordButton: UIButton = {
        var searchPassword = UIButton()
        searchPassword.setTitle("비밀번호 찾기", for: .normal)
        searchPassword.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        searchPassword.backgroundColor = .white
        searchPassword.setTitleColor(.lightGray, for: .normal)
        searchPassword.translatesAutoresizingMaskIntoConstraints = false
        return searchPassword
    }()
    
    private lazy var signInLabel: UILabel = {
        var signInLabel = UILabel()
        signInLabel.text = "계정이 없으신가요?"
        signInLabel.font = UIFont.systemFont(ofSize: 15)
        signInLabel.textColor = .lightGray
        signInLabel.translatesAutoresizingMaskIntoConstraints = false
        return signInLabel
    }()
    
    private lazy var signInButton: UIButton = {
        var signInButton = UIButton()
        signInButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        let title = "회원가입"
        let attributedTitle = NSMutableAttributedString(string: title)
        attributedTitle.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: title.count))
        signInButton.setAttributedTitle(attributedTitle, for: .normal)
        signInButton.backgroundColor = .white
        signInButton.setTitleColor(.lightGray, for: .normal)
        signInButton.translatesAutoresizingMaskIntoConstraints = false
        return signInButton
    }()
    
    private lazy var signUpWithSNSLeadingLine: UIView = {
        var signUpWithSNSLeadingLine = UIView()
        signUpWithSNSLeadingLine.backgroundColor = .black
        signUpWithSNSLeadingLine.translatesAutoresizingMaskIntoConstraints = false
        return signUpWithSNSLeadingLine
    }()
    
    private lazy var signUpWithSNSTrailingLine: UIView = {
        var signUpWithSNSTrailingLine = UIView()
        signUpWithSNSTrailingLine.backgroundColor = .black
        signUpWithSNSTrailingLine.translatesAutoresizingMaskIntoConstraints = false
        return signUpWithSNSTrailingLine
    }()
    
    private lazy var signUpWithSNSLabel: UILabel = {
        var signUpWithSNSLabel = UILabel()
        signUpWithSNSLabel.text = "Sign Up With SNS"
        signUpWithSNSLabel.font = UIFont.systemFont(ofSize: 15)
        signUpWithSNSLabel.translatesAutoresizingMaskIntoConstraints = false
        return signUpWithSNSLabel
    }()
    
    private lazy var kakaoLoginButton: UIButton = {
        var kakaoLoginButton = UIButton()
        kakaoLoginButton.translatesAutoresizingMaskIntoConstraints = false
        kakaoLoginButton.setImage(UIImage(named: "kakao_login_large_wide"), for: .normal)
        return kakaoLoginButton
    }()
    
    private lazy var appleLoginButton: UIButton = {
        var appleLoginButton = UIButton()
        appleLoginButton.translatesAutoresizingMaskIntoConstraints = false
        appleLoginButton.setImage(UIImage(named: "appleid_button"), for: .normal)
        return appleLoginButton
    }()
    
    //TODO: Test를 위해 넣어둠 googleLoginButton 들어갈 예정
    private lazy var kakaoLogoutButton: UIButton = {
        var kakaoLogoutButton = UIButton()
        kakaoLogoutButton.translatesAutoresizingMaskIntoConstraints = false
        kakaoLogoutButton.setTitle("Logout", for: .normal)
        kakaoLogoutButton.setTitleColor(.black, for: .normal)
        return kakaoLogoutButton
    }()
    
    private lazy var searchStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = 20
        return stackView
    }()
    
    private lazy var signInStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = 10
        return stackView
    }()
    
    private lazy var signUpSNSLabelStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalCentering
        return stackView
    }()
    
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        kakaoLoginButton.addTarget(self, action: #selector(kakaoLoginButtonTapped), for: .touchUpInside)
        kakaoLogoutButton.addTarget(self, action: #selector(kakaoLogoutButtonTapped), for: .touchUpInside)
        
        view.addSubviews([logoImage,
                          emailTextField,
                          passwordTextField,
                          loginButton,
                          searchStackView,
                          signInStackView,
                          signUpSNSLabelStackView,
                          kakaoLoginButton,
                          appleLoginButton,
                          kakaoLogoutButton
                         ])
        
        let searchStackViewLeftSpacer = UIView()
        let signInStackViewLeftSpacer = UIView()
        searchStackView.addArrangedSubview(searchStackViewLeftSpacer)
        searchStackView.addArrangedSubview(searchEmailButton)
        searchStackView.addArrangedSubview(searchPasswordButton)
        signInStackView.addArrangedSubview(signInStackViewLeftSpacer)
        signInStackView.addArrangedSubview(signInLabel)
        signInStackView.addArrangedSubview(signInButton)
        signUpSNSLabelStackView.addArrangedSubview(signUpWithSNSLeadingLine)
        signUpSNSLabelStackView.addArrangedSubview(signUpWithSNSLabel)
        signUpSNSLabelStackView.addArrangedSubview(signUpWithSNSTrailingLine)

        NSLayoutConstraint.activate([
            // logoImage Constraints
            logoImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            logoImage.widthAnchor.constraint(equalToConstant: 200),
            logoImage.heightAnchor.constraint(equalToConstant: 200),
            
            // emailTextField Constraints
            emailTextField.topAnchor.constraint(equalTo: logoImage.bottomAnchor, constant: 20),
            emailTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            emailTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // passwordTextField Constraints
            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 10),
            passwordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            passwordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // loginButton Constraints
            loginButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 10),
            loginButton.heightAnchor.constraint(equalToConstant: 50),
            loginButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            loginButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // searchStackView Constraints
            searchStackView.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 20),
            searchStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            searchStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // signInStackView Constraints
            signInStackView.topAnchor.constraint(equalTo: searchStackView.bottomAnchor, constant: 10),
            signInStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            signInStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // signUpSNSLabelStackView Constraints
            signUpWithSNSLeadingLine.widthAnchor.constraint(equalToConstant: 100),
            signUpWithSNSLeadingLine.heightAnchor.constraint(equalToConstant: 2),
            signUpWithSNSTrailingLine.widthAnchor.constraint(equalToConstant: 100),
            signUpWithSNSTrailingLine.heightAnchor.constraint(equalToConstant: 2),
            signUpSNSLabelStackView.topAnchor.constraint(equalTo: signInStackView.bottomAnchor, constant: 30),
            signUpSNSLabelStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            signUpSNSLabelStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // kakaoLoginButton Constraints
            kakaoLoginButton.heightAnchor.constraint(equalToConstant: 50),
            kakaoLoginButton.topAnchor.constraint(equalTo: signUpSNSLabelStackView.bottomAnchor, constant: 30),
            kakaoLoginButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            kakaoLoginButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // kakaoLoginButton Constraints
            appleLoginButton.heightAnchor.constraint(equalToConstant: 50),
            appleLoginButton.topAnchor.constraint(equalTo: kakaoLoginButton.bottomAnchor, constant: 10),
            appleLoginButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            appleLoginButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // kakaoLogoutButton Constraints
            kakaoLogoutButton.heightAnchor.constraint(equalToConstant: 50),
            kakaoLogoutButton.topAnchor.constraint(equalTo: appleLoginButton.bottomAnchor, constant: 10),
            kakaoLogoutButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            kakaoLogoutButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])
    }

    //MARK: - Methods
    func setUserInfo() {
        UserApi.shared.me {(user, error) in
            if let error = error {
                print("setUserInfo Error: \(error.localizedDescription)")
            } else {
                print("setUserInfo nickname: \(user?.kakaoAccount?.profile?.nickname ?? "no nickname")")
                print("setUserInfo email: \(user?.kakaoAccount?.email ?? "no email")")
                print("setUserInfo profileImageUrl: \(String(describing: user?.kakaoAccount?.profile?.profileImageUrl))")
                UserInfo.shared.user?.id = (user?.id!)!
                
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
                                        print("이미 사용자가 존재하는 경우 currentUser 정보 : \(UserInfo.shared.user)")
                                        //TODO: 다음뷰 표시
//                                        let TestViewController = TestViewController()
//                                        TestViewController.modalPresentationStyle = .fullScreen
//                                        self.present(TestViewController, animated: true)
                                        
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
                                                print("fetch 이후 currentUser 정보 : \(UserInfo.shared.user)")
                                                //TODO: 다음뷰 표시
//                                                let TestViewController = TestViewController()
//                                                TestViewController.modalPresentationStyle = .fullScreen
//                                                self.present(TestViewController, animated: true)
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
                                    
                                    let user = User(id: userId, name: nickname, email: email, profileImageUrl: profileImageUrl)
                                    UserInfo.shared.user = user
                                    
                                    print("이메일이 사용중이지 않을때 사용자 정보 저장: \(UserInfo.shared.user)")
                                                    
                                    // Firestore에 사용자 정보 저장
                                    self.saveUserToFirestore(user: UserInfo.shared.user!, userId: String(UserInfo.shared.user!.id))
                                    //TODO: 다음뷰 표시
//                                    let TestViewController = TestViewController()
//                                    TestViewController.modalPresentationStyle = .fullScreen
//                                    self.present(TestViewController, animated: true)
                                }
                                
                            }
                        }
                    }
                }
            }
            
        }
    }
    
    //MARK: - Login/out Methods
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
                    self.setUserInfo()
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
                    self.setUserInfo()
                }
            }
        } else { //카카오톡이 설치되어 있지 않은 경우 웹으로 연결 loginWithKakaoAccount
            UserApi.shared.loginWithKakaoAccount { (oauthToken, error) in
                if let error = error {
                    print("KakaoTalk Web Login Error: \(error.localizedDescription)")
                } else {
                    print("loginWithKakaoAccount() success.")
                    self.setUserInfo()
                }
            }
        }
    }
    
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
extension ViewController: UITextFieldDelegate {
    //textFieldDidChangeSelection
    
    //textFieldDidBeginEditing
    
    //textFieldDidEndEditing
}
