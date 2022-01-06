//
//  ViewController.swift
//  chat
//
//  Created by administrator on 05/01/2022.
//

import UIKit
import Firebase
import FirebaseAuth

class SignUppViewController: UIViewController {

    @IBOutlet weak var user : UITextField!
    @IBOutlet weak var email : UITextField!
    @IBOutlet weak var password : UITextField!
    @IBOutlet weak var rewritepass : UITextField!
    
    
    @IBAction func signUppAction(_ sender: AnyObject){
        if password.text != rewritepass.text {
            let alertController = UIAlertController(title: "Password Incorrect", message: "Please re-type Password", preferredStyle: .alert)
            
            let defultAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
            
            alertController.addAction(defultAction)
            self.present(alertController, animated: true, completion: nil)
        }else {
            Auth.auth().createUser(withEmail: email.text!, password:password.text!){
                (user,error)in
                if error == nil {
                    print("Welcome!")
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "Home")
                    self.present(vc!, animated: true, completion: nil)
                }else{
                    let alertController = UIAlertController(title: "Erorr", message: error?.localizedDescription, preferredStyle: .alert)
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


