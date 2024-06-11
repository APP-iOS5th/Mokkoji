//
//  ProfileEditViewController.swift
//  Mokkoji
//
//  Created by 육현서 on 6/11/24.
//

import UIKit

class ProfileEditViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    private lazy var profileEditName: UITextField = {
        let textfield = UITextField()
        textfield.placeholder = "Name"
        
        return textfield
    }()
    
    private lazy var profileEditMail: UITextField = {
        let textfield = UITextField()
        textfield.placeholder = "E-mail"
        
        return textfield
    }()
    
    private lazy var profileEditNameLabel: UILabel = {
        let nameLabel = UILabel()
        nameLabel.text = "Name: "
        
        return nameLabel
    }()
    
    private lazy var profileEditMailLabel: UILabel = {
        let mailLabel = UILabel()
        mailLabel.text = "E-mail: "
        
        return mailLabel
    }()
    
    // 원래는 UIImagePickerController인데 어떻게 사용해야될지 감이 안옴... ㅠㅜ
    private lazy var profileEditImage: UIImageView = {
        let imageEdit = UIImageView()
        imageEdit.image = UIImage(named: "sponge")
        imageEdit.isUserInteractionEnabled = true
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        imageEdit.addGestureRecognizer(tapGestureRecognizer)
        
        imageEdit.clipsToBounds = true
        imageEdit.layer.borderWidth = 2
        imageEdit.layer.borderColor = UIColor.black.cgColor
        imageEdit.layer.cornerRadius = 150
        imageEdit.backgroundColor = .red
        
        return imageEdit
        
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        self.view.addSubview(profileEditMail)
        self.view.addSubview(profileEditName)
        self.view.addSubview(profileEditNameLabel)
        self.view.addSubview(profileEditMailLabel)
        self.view.addSubview(profileEditImage)
        
        self.navigationItem.title = "PROFILE EDIT"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "cancel", style: .plain, target: self, action: #selector(cancelButton))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "save", style: .plain, target: self, action: #selector(tapSaveButton))
        
        profileEditMail.translatesAutoresizingMaskIntoConstraints = false
        profileEditName.translatesAutoresizingMaskIntoConstraints = false
        profileEditImage.translatesAutoresizingMaskIntoConstraints = false
        profileEditMailLabel.translatesAutoresizingMaskIntoConstraints = false
        profileEditNameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            profileEditName.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 350),
            profileEditName.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 110),
            profileEditMail.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 400),
            profileEditMail.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 110),
            profileEditNameLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 350),
            profileEditNameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            profileEditMailLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 400),
            profileEditMailLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            profileEditImage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            profileEditImage.widthAnchor.constraint(equalToConstant: 300),
            profileEditImage.heightAnchor.constraint(equalToConstant: 300),
            profileEditImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
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
    
    
    // MARK: - Methods
    @objc func imageTapped() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        present(imagePickerController, animated: true)
    }


    
    @objc func cancelButton() {
        dismiss(animated: true)
    }
    
    @objc func tapSaveButton() {
        print("저장 버튼")
    }
}
