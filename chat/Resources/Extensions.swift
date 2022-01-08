//
//  Extensions.swift
//  ChatApp
//
//  Created by Mohammad Al-haddad on 01/01/2022.
//

import Foundation
import UIKit

extension LoginViewController {
    func roundedUI(){
        emailField.layer.cornerRadius = 12
        emailField.layer.borderWidth = 1
        emailField.layer.masksToBounds = true
        
        passwordField.layer.cornerRadius = 12
        passwordField.layer.borderWidth = 1
        passwordField.layer.masksToBounds = true
        
        loginBtn.layer.cornerRadius = 12
        loginBtn.layer.masksToBounds = true
        
    }
}

extension SignUppViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func roundedUI(){
        
        firstNameField.layer.cornerRadius = 12
        firstNameField.layer.borderWidth = 1
        firstNameField.layer.masksToBounds = true
        
        lastNameField.layer.cornerRadius = 12
        lastNameField.layer.borderWidth = 1
        lastNameField.layer.masksToBounds = true
        
        emailField.layer.cornerRadius = 12
        emailField.layer.borderWidth = 1
        emailField.layer.masksToBounds = true
        
        passwordField.layer.cornerRadius = 12
        passwordField.layer.borderWidth = 1
        passwordField.layer.masksToBounds = true
        
        registerBtn.layer.cornerRadius = 12
        registerBtn.layer.masksToBounds = true
        
        profileImage.layer.cornerRadius = profileImage.frame.size.height / 2
        profileImage.layer.masksToBounds = true
        
    }
    
    @objc func didImageTapped(_ sender:UITapGestureRecognizer){
        if sender.state == .ended {
            showImageSelection()
        }
    }
    
    func showImageSelection(){
        let actionSheet = UIAlertController(title: "Profile Picture", message: "How would you like to select a picture?", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        actionSheet.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: { _ in
            self.presentCamera()
        }))
        actionSheet.addAction(UIAlertAction(title: "Choose Photo", style: .default, handler: { _ in
            self.presentPhotoPicker()
        }))
        
        present(actionSheet, animated: true)
    }
    
    func presentCamera() {
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    func presentPhotoPicker() {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.editedImage] as? UIImage {
            profileImage.image = image
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

extension Notification.Name {
    static let didLogInNotification = Notification.Name("didLogInNotification")
}
