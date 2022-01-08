//
//  Storage.swift
//  chat
//
//  Created by administrator on 08/01/2022.
//


import Foundation
import FirebaseStorage

final class StorageManager{
    
    static let shared = StorageManager()
    
    private let storage = Storage.storage().reference()
    
    public typealias UploadCompletion = (Result<String, Error>) -> Void
    
    public func uploadImage(with data:Data, fileName:String, completion: @escaping UploadCompletion){
        
        storage.child("images/\(fileName)").putData(data, metadata: nil, completion: {
            metadata, error in
            
            guard error == nil else{
                completion(.failure(StorageErrors.failedToUpload))
                return
            }
            
            self.storage.child("images/\(fileName)").downloadURL(completion: {
                url, error in
                guard let url = url else {
                    print("Failed To Get URL")
                    completion(.failure(StorageErrors.failedToGetDownloadUrl))
                    return
                }
                
                let urlString = url.absoluteString
                completion(.success(urlString))
                
            })
        })
        
    }
    
    public func downloadURL(for path: String,completion: @escaping (Result<URL, Error>) -> Void) {
            let reference = storage.child(path)
            
            reference.downloadURL { url, error in
                guard let url = url, error == nil else {
                    completion(.failure(StorageErrors.failedToGetDownloadUrl))
                    return
                }
                completion(.success(url))
            }
        }
        
        public enum StorageErrors: Error {
            case failedToUpload
            case failedToGetDownloadUrl
        }
}
