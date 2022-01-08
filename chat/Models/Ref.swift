//
//  Ref.swift
//  chat
//
//  Created by administrator on 08/01/2022.
//

import Foundation
import Firebase
import FirebaseStorage

let REF_USER = "user"
let URL_STORAGE_ROOT = "gs://chat-1170f.appspot.com"
let STORAGE_PROFILE = "profile"
let PROFILE_IMAGE_URL = "profileImageUrl"
let UID = "uid"
let EMAIL = "email"
let USERNAME = "username"
let STATUS = "status"
let USERNAME_ERORR = "Please Enter an username"
let EMAIL_ERORR = "Please Enter an email"
let PASSWORD_ERORR = "Please Enter a password"

class Ref {
    let databaseRoot : DatabaseReference = Database.database().reference()
    var databaseUsers: DatabaseReference {
        return databaseRoot.child(REF_USER)
    }
    
    func databaseSpecificUser(uid : String) -> DatabaseReference {
        return databaseUsers.child(uid)
    }
    
    // Storage Ref
    
    let storageRoot = Storage.storage().reference(forURL: URL_STORAGE_ROOT)
    var storageProfile : StorageReference {
        return storageRoot.child(STORAGE_PROFILE)
    }
    
    func storageSpecificProfile (uid: String) -> StorageReference {
        return storageProfile.child(uid)
    }
    
}
