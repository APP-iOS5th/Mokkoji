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
    
    //MARK: - Properties
    let db = Firestore.firestore()
    
    
    //MARK: - UIComponents
    private lazy var profileEditImage: UIImageView! = {
        let imageEdit = UIImageView()
        if let profileImageUrl = UserInfo.shared.user?.profileImageUrl, let url = URL(string: profileImageUrl.absoluteString) {
            imageEdit.load(url: url)
        }
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
        
        guard let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image: \(info)")
        }
        
        profileEditImage.image = selectedImage

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
        
        guard var user = UserInfo.shared.user else {
            print("tapSaveButton user error")
            return
        }
        guard let userId = UserInfo.shared.user?.id else {
            print("tapSaveButton userId error")
            return
        }
        guard let userImage = profileEditImage.image else {
            return
        }
        uploadImage(image: userImage, pathRoot: userId) { url in
            if let url = url {
                user.profileImageUrl = url
            }
            self.saveUserToFirestore(user: user, userId: userId)
        }
        
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
