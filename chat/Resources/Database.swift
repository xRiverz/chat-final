//
//  Database.swift
//  chat
//
//  Created by administrator on 08/01/2022.
//

import Foundation
import FirebaseDatabase
import ProgressHUD
import SwiftUI

final class Database{
    static let shared = Database()
    
    private let database = Database.database().reference()
    
    static func safeEmail(with email:String) -> String {
        return email.replacingOccurrences(of: ".", with: "-")
    }

    public func userExsist(with email:String, completion: @escaping ((Bool) -> Void)){
        
        let safeEmail = Database.safeEmail(with: email)
        
        database.child(safeEmail).observeSingleEvent(of: .value, with: {
            snaphost in
            guard snaphost.value as? [String:Any] != nil else {
                completion(false)
                return
            }
        })
        
        completion(true)
    }
    
    public func insertUser(with user:ChatUser, completion: @escaping (Bool) -> Void){
        database.child(user.safeEmail).setValue([
            "username":user.user,
            "email":user.email
        ], withCompletionBlock: {
            error , _ in
            guard error == nil else{
                ProgressHUD.showError("Failed To Write To DB")
                completion(false)
                return
            }
            
            self.database.child("users").observeSingleEvent(of: .value, with: {
                snaphost in
                if var users = snaphost.value as? [[String:String]] {
                    
                    users.append(["name":"\(user.user)","email":"\(user.safeEmail)"])
                    
                    self.database.child("users").setValue(users, withCompletionBlock: {
                        error, _ in
                        guard error == nil else {
                            completion(false)
                            return
                        }
                        completion(true)
                    })
                }else{
                    let users : [[String:String]] = [
                        ["name":"\(user.user)","email":"\(user.safeEmail)"]
                    ]
                    
                    self.database.child("users").setValue(users, withCompletionBlock: {
                        error, _ in
                        guard error == nil else {
                            completion(false)
                            return
                        }
                        completion(true)
                    })
                }
                
                
            })
        })
    }
    
    public func getAllUsers(completion: @escaping (Result<[[String:String]], Error>) -> Void){
        database.child("users").observeSingleEvent(of: .value, with: {
            snaphost in
            guard let users = snaphost.value as? [[String:String]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            
            completion(.success(users))
        })
    }
    
    public func getUserData(for email:String, completion: @escaping (Result<[String:Any], Error>) -> Void){
        database.child(email).observeSingleEvent(of: .value, with: {
            snapshot in
            
            guard let userNode = snapshot.value as? [String:Any] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            
            completion(.success(userNode))
        })
    }
    
    // MARK: Conversations
    
    /// creates a new conversation with target user email and first message sent
    public func createNewConversation(otherUserEmail: String, name:String, firstMessage: Message, completion: @escaping (Bool) -> Void) {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String, let myName = UserDefaults.standard.value(forKey: "name")  else {
            print("null")
            return
        }
        
        let safeEmail = Database.safeEmail(with: email)
        let ref = database.child(safeEmail)
        ref.observeSingleEvent(of: .value, with: { [weak self]
            snapshot in
            guard var userNode = snapshot.value as? [String:Any] else {
                completion(false)
                ProgressHUD.showFailed("User Not Found")
                return
            }
            
            var message = ""
            
            switch firstMessage.kind {
            
            case .text(let messageTxt):
                message = messageTxt
            case .attributedText(_):
                break
            case .photo(_):
                break
            case .video(_):
                break
            case .location(_):
                break
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
            case .linkPreview(_):
                break
            case .custom(_):
                break
            }
            
            let convID = "conversation_\(firstMessage.messageId)"
            
            let newConv : [String:Any] = [
                "id": convID,
                "otherEmail": otherUserEmail,
                "name" : name,
                "latestMessage" : [
                    "date":MessageViewController.dateFormatter.string(from: firstMessage.sentDate),
                    "message":message,
                    "isRead":false
                ]
            ]
            
            
            
            let recipient_newConv : [String:Any] = [
                "id": convID,
                "otherEmail": safeEmail,
                "name" : myName,
                "latestMessage" : [
                    "date":MessageViewController.dateFormatter.string(from: firstMessage.sentDate),
                    "message":message,
                    "isRead":false
                ]
            ]
            
            //For Recipent
            
            self?.database.child("\(otherUserEmail)/conversations").observeSingleEvent(of: .value, with: { [weak self]
                snapshot in
                if var conversations = snapshot.value as? [[String:Any]] {
                    conversations.append(newConv)
                    self?.database.child("\(otherUserEmail)/conversations").setValue(conversations)
                }else {
                    self?.database.child("\(otherUserEmail)/conversations").setValue([recipient_newConv])
                }
            })
            
            
            
            
            
            
            // For Current User
            if var conversations = userNode["conversations"] as? [[String:Any]] {
                conversations.append(newConv)
                userNode["conversations"] = conversations
            }else {
                userNode["conversations"] = [newConv]
            }
            
            ref.setValue(userNode, withCompletionBlock: { [weak self]
                error, _ in
                guard error == nil else {
                    completion(false)
                    print(error?.localizedDescription)
                    return
                }
                self?.finishConversation(id: convID, name: name, firstMessage: firstMessage, completion: completion)
            })
        })
        
    }
    
    private func finishConversation(id:String, name:String, firstMessage:Message, completion: @escaping ((Bool)-> Void)) {
        
        var messageContent = ""
        
        switch firstMessage.kind {
        
        case .text(let messageTxt):
            messageContent = messageTxt
        case .attributedText(_):
            break
        case .photo(_):
            break
        case .video(_):
            break
        case .location(_):
            break
        case .emoji(_):
            break
        case .audio(_):
            break
        case .contact(_):
            break
        case .linkPreview(_):
            break
        case .custom(_):
            break
        }
        
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        
        
        
        let message : [String:Any] = [
            "id":firstMessage.messageId,
            "type":firstMessage.kind.description,
            "content":messageContent,
            "date":MessageViewController.dateFormatter.string(from: firstMessage.sentDate),
            "sender_email" : Database.safeEmail(with: email),
            "isRead":false,
            "name" : name
        ]
        
        let messages : [String:Any] = [
            "messages": [
                message
            ]
        ]
        
        database.child(id).setValue(messages,withCompletionBlock: {
            error, _ in
            guard error == nil else {
                completion(false)
                return
            }
            
            completion(true)
        })
    }
    
    /// Fetches and returns all conversations for the user with
    public func getAllConversations(for email: String, completion: @escaping (Result<[Conversation], Error>) -> Void) {
        database.child("\(email)/conversations").observe(.value, with: {
            snapshot in
            guard let value = snapshot.value as? [[String: Any]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            
            let conversations : [Conversation] = value.compactMap({
                dictonary in
                guard let id = dictonary["id"] as? String,
                      let name = dictonary["name"] as? String,
                      let otherEmail = dictonary["otherEmail"] as? String,
                      let latestMessage = dictonary["latestMessage"] as? NSDictionary,
                      let isRead = latestMessage["isRead"] as? Bool,
                      let date = latestMessage["date"] as? String,
                      let message = latestMessage["message"] as? String else {
                    return nil
                }
                
                let messageObj = LatestMessage(date: date, message: message, isRead: isRead)
                
                return Conversation(id: id, name: name, otherEmail: otherEmail, latestMessage: messageObj)
            })
            
            completion(.success(conversations))
        })
    }
    
    
    /// gets all messages from a given conversation
    public func getAllMessagesForConversation(id: String, completion: @escaping (Result<[Message], Error>) -> Void) {
        database.child("\(id)/messages").observe(.value, with: {
            snapshot in
            guard let value = snapshot.value as? [[String: Any]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            
            let messages : [Message] = value.compactMap({
                dictonary in
                guard let content = dictonary["content"] as? String,
                      let dateString = dictonary["date"] as? String,
                      let id = dictonary["id"] as? String,
                      let isRead = dictonary["isRead"] as? Bool,
                      let name = dictonary["name"] as? String,
                      let senderEmail = dictonary["sender_email"] as? String,
                      let type = dictonary["type"] as? String,
                      let date = ChatViewController.dateFormatter.date(from: dateString) else {
                    return nil
                }
                
                let sender = Sender(photoURL: "", senderId: senderEmail, displayName: name)
                
                return Message(sender: sender, messageId: id, sentDate: date, kind: .text(content))
                
            })
            
            completion(.success(messages))
        })
    }
    
    ///// Sends a message with target conversation and message
    public func sendMessage(to conversation: String, otherEmail:String, name:String, newMessage: Message, completion: @escaping (Bool) -> Void) {
        
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        
        let safeEmail = Database.safeEmail(with: email)
        
        
        database.child("\(conversation)/messages").observeSingleEvent(of: .value, with: {
            [weak self]
            snapshot in
            guard var messages = snapshot.value as? [[String:Any]], let strongSelf = self else {
                completion(false)
                return
            }
            
            var messageContent = ""
            
            switch newMessage.kind {
            
            case .text(let messageTxt):
                messageContent = messageTxt
            case .attributedText(_):
                break
            case .photo(_):
                break
            case .video(_):
                break
            case .location(_):
                break
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
            case .linkPreview(_):
                break
            case .custom(_):
                break
            }
            
            
            let newMessageEnt : [String:Any] = [
                "id":newMessage.messageId,
                "type":newMessage.kind.description,
                "content":messageContent,
                "date":ChatViewController.dateFormatter.string(from: newMessage.sentDate),
                "sender_email" : safeEmail,
                "isRead":false,
                "name" : name
            ]
            
            messages.append(newMessageEnt)
            strongSelf.database.child("\(conversation)/messages").setValue(messages) {
                error, _ in
                guard error == nil else {
                    completion(false)
                    return
                }
                
                strongSelf.database.child("\(safeEmail)/conversations").observeSingleEvent(of: .value, with: {
                    snapshot in
                    
                    guard var currentUserConvs = snapshot.value as? [[String: Any]] else {
                        completion(false)
                        return
                    }
                    
                    var targetConv : [String:Any]?
                    var pos = 0
                    
                    let updatedMessage : [String:Any] = [
                        "date":ChatViewController.dateFormatter.string(from: newMessage.sentDate),
                        "isRead":false,
                        "message":messageContent
                    ]
                    
                    for conv in currentUserConvs {
                        if let currentID = conv["id"] as? String, currentID == conversation {
                            targetConv = conv
                            break
                        }
                        
                        pos += 1
                    }
                    
                    guard var targetConver = targetConv else {
                        completion(false)
                        return
                    }
                    
                    targetConver["latestMessage"] = updatedMessage
                    currentUserConvs[pos] = targetConver
                    
                    strongSelf.database.child("\(safeEmail)/conversations").setValue(currentUserConvs, withCompletionBlock: {
                        error, _ in
                        guard error == nil else{
                            completion(false)
                            return
                        }
                        
                        strongSelf.database.child("\(otherEmail)/conversations").observeSingleEvent(of: .value, with: {
                            snapshot in
                            
                            guard var otherUserConvs = snapshot.value as? [[String: Any]] else {
                                completion(false)
                                return
                            }
                            
                            var targetConv : [String:Any]?
                            var pos = 0
                            
                            let updatedMessage : [String:Any] = [
                                "date":ChatViewController.dateFormatter.string(from: newMessage.sentDate),
                                "isRead":false,
                                "message":messageContent
                            ]
                            
                            for conv in otherUserConvs {
                                if let currentID = conv["id"] as? String, currentID == conversation {
                                    targetConv = conv
                                    break
                                }
                                
                                pos += 1
                            }
                            
                            guard var targetConver = targetConv else {
                                completion(false)
                                return
                            }
                            
                            targetConver["latestMessage"] = updatedMessage
                            otherUserConvs[pos] = targetConver
                            
                            strongSelf.database.child("\(otherEmail)/conversations").setValue(otherUserConvs, withCompletionBlock: {
                                error, _ in
                                guard error == nil else{
                                    completion(false)
                                    return
                                }
                                
                                completion(true)
                            })
                        })
                    })
                })
            }
        })
    }
    
    public func conversationExsist(with otherEmail:String, completion: @escaping (Result<String,Error>) -> Void){
        let otherSafeEmail = Database.safeEmail(with: otherEmail)
        guard let senderEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        let safeSenderEmail = Database.safeEmail(with: senderEmail)
    }
    
    public enum DatabaseError: Error {
        case failedToFetch
    }
}



struct ChatUser {
    let name:String
    let avatar:Image
    let email:String
    
    var safeEmail:String {
        let safeEmail = email.replacingOccurrences(of: ".", with: "-")
        return safeEmail
    }
    // usersafeemail_profilepicture.png
    var profileImage : String {
        return "\(safeEmail)_profile_picture.png"
    }
}
