//
//  LoginViewController.swift
//  chat
//
//  Created by administrator on 05/01/2022.
//

import UIKit
import Firebase
import FirebaseAuth

class LoginViewController: UIViewController {
    
    @IBOutlet weak var email : UITextField!
    @IBOutlet weak var password : UITextField!
    
    @IBAction func LoginnAction(_ sender: AnyObject){
        
        if self.email.text == "" || self.password.text == "" {
            let alertController = UIAlertController(title: "Error", message: "Please Enter an email and password", preferredStyle: .alert)
            let defualtAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defualtAction)
            self.present(alertController, animated: true, completion: nil)
            
        }else{
            Auth.auth().signIn(withEmail: self.email.text! , password: self.password.text!){ (user,erorr)in
                
                if erorr == nil {
                    print("Welcome Back!")
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "Home")
                    self.present(vc!, animated: true, completion: nil)
                }else {
                    let alertController = UIAlertController(title: "Error", message: "somthing went wrong", preferredStyle: .alert)
                    let defualtAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                
                    alertController.addAction(defualtAction)
                    self.present(alertController, animated: true, completion: nil)
                    
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
      
    }


}

