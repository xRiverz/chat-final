//
//  ChatViewController.swift
//  chat
//
//  Created by administrator on 08/01/2022.
//


import UIKit
import MessageKit
import InputBarAccessoryView

struct Message : MessageType {
    var sender:SenderType
    var messageId: String
    var sentDate: Date
    var kind:MessageKind
}

extension MessageKind {
    var description : String {
        switch self {
        case .text(_):
            return "text"
        case .attributedText(_):
            return "attribute"
        case .photo(_):
            return "photo"
        case .video(_):
            return "video"
        case .location(_):
            return "location"
        case .emoji(_):
            return "emoji"
        case .audio(_):
            return "audio"
        case .contact(_):
            return "contact"
        case .linkPreview(_):
            return "linkPreview"
        case .custom(_):
            return "custom"
        }
    }
}

struct Sender:SenderType {
    var photoURL:String
    var senderId: String
    var displayName: String
}

class ChatViewController: MessagesViewController {
    
    public static var dateFormatter : DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .long
        formatter.locale = .current
        return formatter
    }()
    
    var otherEmail:String
    var conversationID: String?
    var isNew = false
    
    init(with email:String, id conversationID:String?) {
        self.conversationID = conversationID
        otherEmail = email
        super.init(nibName: nil, bundle: nil)
        if let conversationID = conversationID {
            listenForMessages(id:conversationID)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    var messages : [Message] = []
    
    var selfSender : Sender? {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return nil
        }
        
        let safeEmail = DatabaseManager.safeEmail(with: email)
        
        return Sender(photoURL: "", senderId: safeEmail, displayName: "Me")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        messageInputBar.becomeFirstResponder()
    }
    
    func listenForMessages(id:String){
        DatabaseManager.shared.getAllMessagesForConversation(id: id, completion: {
            [weak self] result in
            switch result{
            case .success(let messages):
                guard !messages.isEmpty else {
                    return
                }
                self?.messages = messages
                DispatchQueue.main.async {
                    self?.messagesCollectionView.reloadData()
                }
            case .failure(let error):
                print(error)
            }
        })
    }
}

extension ChatViewController : MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate, InputBarAccessoryViewDelegate {
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty, let selfSender = self.selfSender, let messageID = createMessageID() else {
            return
        }
        
        let message = Message(sender: selfSender, messageId: messageID, sentDate: Date(), kind: .text(text))
        if isNew{
            print(isNew)
            DatabaseManager.shared.createNewConversation(otherUserEmail: otherEmail, name: self.title ?? "User", firstMessage: message, completion: { [weak self]
                success in
                if success {
                    print("message sent")
                    self?.isNew = false
                    let newConvID = "conversation_\(message.messageId)"
                    self?.listenForMessages(id: newConvID)
                    self?.messageInputBar.inputTextView.text = nil
                }else{
                    print("message not sent")
                }
            })
        }else {
            guard let convID = self.conversationID else {
                return
            }
            DatabaseManager.shared.sendMessage(to: convID, otherEmail: otherEmail, name:self.title ?? "User", newMessage: message, completion: {
                success in
                if success {
                    print("message sent")
                }else{
                    print("message not sent")
                }
            })
        }
        
        func backgroundColor(for message: MessageType, at  indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
            let sender = message.sender
            
            if sender.senderId == selfSender.senderId {
                return .link
            }
            
            return .secondarySystemBackground
        }
    }
    
    func createMessageID() -> String? {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return nil
        }
        
        return "\(otherEmail)_\(DatabaseManager.safeEmail(with: email))"
    }
    
    func currentSender() -> SenderType {
        if let sender = selfSender {
            return sender
        }
        
        fatalError("selfSender is Null")
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        messages.count
    }
    
    
}
