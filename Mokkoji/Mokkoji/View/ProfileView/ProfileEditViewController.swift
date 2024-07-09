//
//  ProfileEditViewController.swift
//  Mokkoji
//
//  Created by 육현서 on 6/11/24.
//

import UIKit
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class ProfileEditViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let db = Firestore.firestore()
    var onSave: ((String, String, UIImage) -> Void)?
    
    private lazy var profileEditImage: UIImageView! = {
        let imageEdit = UIImageView()
        imageEdit.image = UIImage(systemName: "person.circle")
        imageEdit.isUserInteractionEnabled = true
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        imageEdit.addGestureRecognizer(tapGestureRecognizer)
        
        imageEdit.clipsToBounds = true
        imageEdit.contentMode = .scaleAspectFill
        imageEdit.layer.borderWidth = 2
        imageEdit.layer.borderColor = UIColor.white.cgColor
        imageEdit.layer.cornerRadius = 75
        imageEdit.backgroundColor = .white
        
        return imageEdit
    }()
    
    private lazy var profileEditNameLabel: UILabel = {
        let nameLabel = UILabel()
        nameLabel.text = "Name"
        nameLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        nameLabel.textColor = .darkGray
        
        return nameLabel
    }()
    
    private lazy var profileEditName: UITextField! = {
        let textfield = UITextField()
        
        if let userName = UserInfo.shared.user?.name {
            textfield.placeholder = userName
        } else {
            textfield.placeholder = "Enter your name"
        }
        
        textfield.borderStyle = .roundedRect
        textfield.layer.borderColor = UIColor.lightGray.cgColor
        textfield.layer.borderWidth = 1
        textfield.layer.cornerRadius = 8
        textfield.setLeftPaddingPoints(10)
        
        return textfield
    }()
    
    private lazy var profileEditMailLabel: UILabel = {
        let mailLabel = UILabel()
        mailLabel.text = "E-mail"
        mailLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        mailLabel.textColor = .darkGray
        
        return mailLabel
    }()
    
    private lazy var profileEditMail: UITextField! = {
        let textfield = UITextField()
        
        if let userEmail = UserInfo.shared.user?.email {
            textfield.placeholder = userEmail
        } else {
            textfield.placeholder = "Enter your email"
        }
        
        textfield.borderStyle = .roundedRect
        textfield.layer.borderColor = UIColor.lightGray.cgColor
        textfield.layer.borderWidth = 1
        textfield.layer.cornerRadius = 8
        textfield.setLeftPaddingPoints(10)
        
        return textfield
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        self.navigationItem.title = "Edit Profile"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelButton))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(tapSaveButton))
        
        self.view.addSubview(profileEditImage)
        self.view.addSubview(profileEditNameLabel)
        self.view.addSubview(profileEditName)
        self.view.addSubview(profileEditMailLabel)
        self.view.addSubview(profileEditMail)
        
        profileEditImage.translatesAutoresizingMaskIntoConstraints = false
        profileEditNameLabel.translatesAutoresizingMaskIntoConstraints = false
        profileEditName.translatesAutoresizingMaskIntoConstraints = false
        profileEditMailLabel.translatesAutoresizingMaskIntoConstraints = false
        profileEditMail.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            profileEditImage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            profileEditImage.widthAnchor.constraint(equalToConstant: 150),
            profileEditImage.heightAnchor.constraint(equalToConstant: 150),
            profileEditImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            profileEditNameLabel.topAnchor.constraint(equalTo: profileEditImage.bottomAnchor, constant: 30),
            profileEditNameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            profileEditName.topAnchor.constraint(equalTo: profileEditNameLabel.bottomAnchor, constant: 8),
            profileEditName.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            profileEditName.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            profileEditName.heightAnchor.constraint(equalToConstant: 40),
            
            profileEditMailLabel.topAnchor.constraint(equalTo: profileEditName.bottomAnchor, constant: 20),
            profileEditMailLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            profileEditMail.topAnchor.constraint(equalTo: profileEditMailLabel.bottomAnchor, constant: 8),
            profileEditMail.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            profileEditMail.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            profileEditMail.heightAnchor.constraint(equalToConstant: 40),
        ])
    }
    
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

    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print("\(info)")
        
        guard let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image: \(info)")
        }
        uploadImage(image: selectedImage, pathRoot: UserInfo.shared.user!.id) { url in
            let userRef = self.db.collection("users").document("LmpQJXa9dYVwgP8vOOTX6RAEKaV2")
            userRef.updateData(["profileImageUrl" : url?.absoluteString] )
                print("Profile Edit Information saved")
        }
        
        let smallerImage = selectedImage.preparingThumbnail(of: CGSize(width: 150, height: 150))
        profileEditImage.image = smallerImage
        dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
    
    @objc func imageTapped() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        present(imagePickerController, animated: true)
    }
    
    @objc func cancelButton() {
        dismiss(animated: true)
    }
    
    //TODO: - 파이어 베이스 저장 기능 추가
    @objc func tapSaveButton() {
        guard let text = profileEditName.text,
              let text2 = profileEditMail.text,
              let image1 = profileEditImage.image
        else { return }
        
//        // 사용자의 데이터를 기반으로 User 객체 생성
//        let user = User(id: UserInfo.shared.user?.id, name: text, email: text2, profileImageUrl: <#T##URL#>)
//        
        // 사용자 ID 가져오기 (예시: UserInfo.shared.user?.id)
        guard let userId = UserInfo.shared.user?.id else {
            print("User ID not found")
            return
        }
        
        // Firestore에 사용자 데이터 저장
//        saveUserToFirestore(user: user, userId: userId)
//        
        // 클로저 호출
        onSave?(text, text2, image1)
        
        // 뷰 컨트롤러 닫기
        dismiss(animated: true, completion: nil)
    }

    func saveUserToFirestore(user: User, userId: String) {
        let userRef = db.collection("users").document(userId)
        do {
            try userRef.setData(from: user)
            print("Profile Edit Information saved")
        } catch let error {
            print("Firestore Writing Error: \(error)")
        }
    }

}

private extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
}
