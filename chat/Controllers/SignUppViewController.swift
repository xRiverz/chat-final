//
//  ViewController.swift
//  chat
//
//  Created by administrator on 05/01/2022.
//

import UIKit
import FirebaseAuth
import JGProgressHUD




class SignUppViewController: UIViewController {
    
        
        @IBOutlet weak var firstNameField:UITextField!
        @IBOutlet weak var lastNameField:UITextField!
        @IBOutlet weak var emailField:UITextField!
        @IBOutlet weak var passwordField:UITextField!
        @IBOutlet weak var profileImage:UIImageView!
        @IBOutlet weak var registerBtn:UIButton!

        

        override func viewDidLoad() {
            super.viewDidLoad()
            roundedUI()
            let tapGR = UITapGestureRecognizer(target: self, action: #selector(didImageTapped))
            profileImage.addGestureRecognizer(tapGR)
            profileImage.isUserInteractionEnabled = true

            // Do any additional setup after loading the view.
        }
        
        @IBAction func registerButtonPressed(_ sender:UIButton){
            
            guard let firstName = firstNameField.text, let lastName = lastNameField.text, let email = emailField.text, let password = passwordField.text else {
                return
            }
            
            
            DatabaseManager.shared.userExsist(with: email, completion: {
                exsist in
                
                guard !exsist else {
                    return
                }
                
                
                
                Auth.auth().createUser(withEmail: email, password: password, completion: {
                    [weak self] authRes, error in
                    guard let strongSelf = self else {
                        return
                    }
                    
                    DispatchQueue.main.async {
                        
                    }
                    
                    
                    let user = ChatUser(firstName: firstName, lastName: lastName, email: email)
                    
                    DatabaseManager.shared.insertUser(with: user, completion: {
                        sucess in
                        if sucess {
                          
                            guard let image = strongSelf.profileImage.image, let data = image.pngData() else {
                                return
                            }
                            let fileName = user.profileImage
                            StorageManager.shared.uploadImage(with: data, fileName: fileName, completion: {
                                result in
                                switch result{
                                case .success(let downloadURL):
                                    print(downloadURL)
                                case .failure(let error):
                                    print(error)
                                }
                            })
                        }
                    })
                    
                    UserDefaults.standard.setValue(email, forKey: "email")
                    UserDefaults.standard.setValue("\(firstName) \(lastName)", forKey: "name")
                    
                    strongSelf.navigationController?.dismiss(animated: true, completion: nil)
                })
                
            })
        }
        

    }
