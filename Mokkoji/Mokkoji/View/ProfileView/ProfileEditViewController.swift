//
//  ProfileEditViewController.swift
//  Mokkoji
//
//  Created by 육현서 on 6/11/24.
//

import UIKit

class ProfileEditViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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
         imageEdit.layer.cornerRadius = 150
         imageEdit.backgroundColor = .white
         
         return imageEdit
     }()
    
    private lazy var profileEditNameLabel: UILabel = {
        let nameLabel = UILabel()
        nameLabel.text = "Name: "
        
        return nameLabel
    }()
    
    private lazy var profileEditName: UITextField! = {
        let textfield = UITextField()
        textfield.placeholder = "Name"
        
        return textfield
    }()
    
    private lazy var profileEditMailLabel: UILabel = {
        let mailLabel = UILabel()
        mailLabel.text = "E-mail: "
        
        return mailLabel
    }()
    
    private lazy var profileEditMail: UITextField! = {
        let textfield = UITextField()
        textfield.placeholder = "E-mail"
        
        return textfield
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        self.navigationItem.title = "PROFILE EDIT"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "cancel", style: .plain, target: self, action: #selector(cancelButton))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "save", style: .plain, target: self, action: #selector(tapSaveButton))
        
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
            
            profileEditImage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            profileEditImage.widthAnchor.constraint(equalToConstant: 300),
            profileEditImage.heightAnchor.constraint(equalToConstant: 300),
            profileEditImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            profileEditNameLabel.topAnchor.constraint(equalTo: profileEditImage.bottomAnchor, constant: 10),
            profileEditNameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            profileEditName.topAnchor.constraint(equalTo: profileEditImage.bottomAnchor, constant: 10),
            profileEditName.leadingAnchor.constraint(equalTo: profileEditNameLabel.trailingAnchor),
            
            profileEditMailLabel.topAnchor.constraint(equalTo: profileEditNameLabel.bottomAnchor, constant: 10),
            profileEditMailLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            profileEditMail.topAnchor.constraint(equalTo: profileEditName.bottomAnchor, constant: 10),
            profileEditMail.leadingAnchor.constraint(equalTo: profileEditMailLabel.trailingAnchor),
            ])
       }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image: \(info)")
        }
        let smallerImage = selectedImage.preparingThumbnail(of: CGSize(width: 300, height: 300))
        profileEditImage.image = smallerImage
        dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }

    // MARK: - 이미지 피커 (플리스트 추가 필요)
    @objc func imageTapped() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        present(imagePickerController, animated: true)
    }


    
    @objc func cancelButton() {
        dismiss(animated: true)
    }
    
    // 이름, 메일, 프로필 사진 변경 값 저장
    @objc func tapSaveButton() {
        guard let text = profileEditName.text, 
              let text2 = profileEditMail.text,
              let image1 = profileEditImage.image
        else { return }
        onSave?(text, text2, image1)
        dismiss(animated: true, completion: nil)
    }
}
