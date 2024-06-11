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
    private lazy var profileImageSetButton: UIButton = {
       var button = UIButton()
        button.setImage(UIImage(systemName: "pencil.circle.fill"), for: .normal)
        button.backgroundColor = .blue
        button.addTarget(self, action: #selector(profileImageSetButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    //MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
                    
        self.view.backgroundColor = .white
        
        view.addSubview(profileImageSetButton)
        
        NSLayoutConstraint.activate([
            profileImageSetButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            profileImageSetButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            profileImageSetButton.widthAnchor.constraint(equalToConstant: 100),
            profileImageSetButton.heightAnchor.constraint(equalToConstant: 100)
        ])
        
    }
    
    //MARK: - Methods
    @objc func profileImageSetButtonTapped() {
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
