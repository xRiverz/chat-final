//
//  UserApi.swift
//  chat
//
//  Created by administrator on 08/01/2022.
//

import Foundation
import FirebaseAuth
import Firebase
import UIKit
import ProgressHUD
import FirebaseStorage

class UserApi {
    func signUp(withUsername username:String, email: String, password: String, image: UIImage?, onSuccess: @escaping() -> Void, onError:
                @escaping(_ errorMessage: String) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) {
            (authDataResult, error) in
            if erorr != nil{
                ProgressHUD.showError(error!.localizedDescription)
            return
        }
                if let authData = authDataResult {
                        let dict: Dictionary<String, Any> = [
                            UID : authData.user.uid,
                            EMAIL : authData.user.email,
                            USERNAME : username,
                            PROFILE_IMAGE_URL:"",
                            STATUS:"Welcome"
                        ]
                        guard let imageSelected = image else {
                            ProgressHUD.showError("Please choose your peofile image")
                            return
                        }
                        guard let imageData = imageSelected.jpegData(compressionQuality: 0.4) else {
                            return
                        }
                    let storageProfile = Ref().storageSpecificProfile(uid: authData.user.uid)
                    let metadata = StorageMetadata()
                    metadata.contentType = "image/jpg"
                    
                    Storage.savePhoto(username: username, uid: authData.user.uid, data: imageData, metadata: metadata, storageProfileRef: storageProfile, dict: dict, onSuccess: {
                        onSuccess()
                    }, onError: {
                        (errorMessage) in onError(errorMessage)
                    })
                    
                
                }
    }}
    

