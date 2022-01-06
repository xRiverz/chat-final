//
//  EditViewController.swift
//  chat
//
//  Created by administrator on 06/01/2022.
//

import Foundation
import UIKit
import Firebase

    

//class EditViewController : UIViewController, UITextFieldDelegate {
//    
//    @IBOutlet weak var profileImageView : UIImageView!
//    @IBOutlet weak var changeBtn : UIButton!
//    
//    var imagePicker:UIImagePickerController
//    
//    imagePicker = UIImagePickerController()
//    imagePicker.allowsEditing = true
//    imagePicker.sourceType = .photoLibrary
//    imagePicker.delegate = self
//}
//func openImagePicker(_ sender:Any){
//    self.present(imagePicker, animate: true, completion: nil)
//}
//
//extension HomeViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
//    
//    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
//        picker.dismiss(animated: true, completion: nil)
//    }
//    private func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
//        if (info[UIImagePickerControllerEditedImage.rawValue] as? UIImage) != nilUIImagePickerController.InfoKey.editedImage
//            self.profileImageView.image = pickedImg
//    }
//}
