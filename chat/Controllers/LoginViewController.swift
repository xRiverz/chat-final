//
//  LoginViewController.swift
//  chat
//
//  Created by administrator on 05/01/2022.
//

import UIKit
import FirebaseAuth
import JGProgressHUD

class LoginViewController: UIViewController {
        
        @IBOutlet weak var emailField:UITextField!
        @IBOutlet weak var passwordField:UITextField!
        @IBOutlet weak var loginBtn:UIButton!
        
        let spinner = JGProgressHUD(style: .dark)
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
           
        }
        
        @objc func didTapRegister(){
            let registerVC = storyboard?.instantiateViewController(identifier: "Main") as! SignUppViewController
            navigationController?.pushViewController(registerVC, animated: true)
        }

        @IBAction func loginButtonPressed(_ sender:UIButton){
            
            guard let email = emailField.text, let password = passwordField.text else {
        return
            }
            
            spinner.show(in: view)
            Auth.auth().signIn(withEmail: email, password: password, completion: {
                [weak self] _, error in
                guard let strongSelf = self else {
                    return
                }
                
                DispatchQueue.main.async {
                    strongSelf.spinner.dismiss(animated: true)
                }
                
                guard error == nil else{
                    print(error?.localizedDescription ?? "")
                    return
                }
                
                let safeEmail  = DatabaseManager.safeEmail(with: email)
                
                DatabaseManager.shared.getUserData(for: safeEmail, completion: {
                    result in
                    switch result{
                    case .success(let userNode):
                        guard  let firstName = userNode["firstName"] as? String, let lastName = userNode["lastName"] as? String else {
                            return
                        }
                        
                        UserDefaults.standard.setValue("\(firstName) \(lastName)", forKey: "name")
                        
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                    
                })
                
                
                UserDefaults.standard.setValue(email, forKey: "email")
                
                strongSelf.navigationController?.dismiss(animated: true, completion: nil)
               
            })
        }
        
    }
