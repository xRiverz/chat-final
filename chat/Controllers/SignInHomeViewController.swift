//
//  SignInHomeViewController.swift
//  chat
//
//  Created by administrator on 09/01/2022.
//

import Foundation
import UIKit

class SignInHomeViewController : UIViewController {
    
    @IBOutlet weak var username : UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let myName = UserDefaults.standard.value(forKey: "name") as? String else {
            return
        }
        
        username.text = myName
        
        UserDefaults.standard.setValue(nil, forKey: "name")
    }
   
}
