//
//  HomeViewController.swift
//  chat
//
//  Created by administrator on 06/01/2022.
//

import UIKit
import FirebaseAuth
import SDWebImage

class ProfileViewController: UIViewController {

    @IBOutlet weak var userEmail: UILabel!
        @IBOutlet weak var profileImage: UIImageView!
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            
            profileImage.layer.cornerRadius = profileImage.frame.size.height / 2
            profileImage.layer.masksToBounds = true
            
            
            guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
                return
            }
            
            setProfileImage(email)
            userEmail.text = email
            
            
            // Do any additional setup after loading the view.
            UserDefaults.standard.setValue(nil, forKey: "email")
            UserDefaults.standard.setValue(nil, forKey: "name")    }

        
        @IBAction func signoutButtonPressed(_ sender:UIButton){
            do{
                try Auth.auth().signOut()
            }catch{
                print(error.localizedDescription)
            }
            
            
            
            let loginVC = storyboard?.instantiateViewController(identifier: "LoginVC") as! LoginViewController
            let nav = UINavigationController(rootViewController: loginVC)
            nav.modalPresentationStyle = .fullScreen
            tabBarController?.present(nav, animated: true, completion: {
                [weak self] in
                
                self?.tabBarController?.selectedIndex = 0
            })
            
        }
        
        func setProfileImage(_ email: String) {
            let safeEmail = DatabaseManager.safeEmail(with: email)
            let fileName = "\(safeEmail)_profile_picture.png"
            let path = "images/\(fileName)"
            
            StorageManager.shared.downloadURL(for: path, completion: {result in
                switch result {
                case .success(let url):
                    self.profileImage.sd_setImage(with: url, placeholderImage: UIImage(systemName: "person.circle"))
                case .failure(let error):
                    print(error)
                }
            })
        }

    }


