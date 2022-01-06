//
//  HomeViewController.swift
//  chat
//
//  Created by administrator on 06/01/2022.
//

import UIKit
import Firebase
import FirebaseAuth
import RealmSwift

class HomeViewController: UIViewController {
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var phoneNum: UILabel!
    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var image: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let pUserName = PFUser.currentUser()?["username"] as? String {
            self.name.text = pUserName
    }
   
}
}
