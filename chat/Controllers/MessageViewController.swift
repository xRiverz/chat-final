//
//  MessageViewController.swift
//  chat
//
//  Created by administrator on 06/01/2022.
//


import UIKit
import FirebaseAuth

struct Conversation {
    var id: String
    var name:String
    var otherEmail:String
    var latestMessage: LatestMessage
}

struct LatestMessage {
    var date:String
    var message: String
    var isRead:Bool
}

class MessageViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noLabel:UILabel!
    
    var conversations : [Conversation] = []
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        validateAuth()
    }
    
    private var conversationObserver : NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Chats"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(didTapCompose))
        
        
        setupTable()
        tableView.isHidden = true
        noLabel.isHidden = true
        fetchConv()
        startListenForConversations()
        
        
        conversationObserver = NotificationCenter.default.addObserver(forName: .didLogInNotification, object: nil, queue: .main, using: { [weak self] _ in
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.startListenForConversations()
        })
    }
    
    func startListenForConversations(){
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        
        if let observer = conversationObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        
        
        let safeEmail = DatabaseManager.safeEmail(with: email)
        
        
        DatabaseManager.shared.getAllConversations(for: safeEmail, completion: {
            [weak self] result in
            switch result {
            case .success(let conversations):
                self?.conversations = conversations
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
                
            case .failure(let error):
                print(error)
            }
        })
        
    }
    
    @objc func didTapCompose(){
        let newVC = storyboard?.instantiateViewController(identifier: "NewVC") as! NewMessageViewController
        newVC.completion = {
            [weak self] result in
            
            let currentConversations = self?.conversations
            
            if let targetConversation = currentConversations?.first(where: {
                $0.otherEmail == DatabaseManager.safeEmail(with: result.email)
            }) {
                print("Here")
                let chatVC = ChatViewController(with: targetConversation.otherEmail, id:targetConversation.id)
                chatVC.isNew = false
                chatVC.title = targetConversation.name
                chatVC.navigationItem.largeTitleDisplayMode = .never
                self?.navigationController?.pushViewController(chatVC, animated: true)
            }else{
                print("Here (1)")
                self?.createConv(result:result)
            }
        }
        let newNav = UINavigationController(rootViewController: newVC)
        present(newNav, animated: true, completion: nil)
    }
    
    func createConv(result:SearchResult){
        print(result)
        let name = result.name
        let email = result.email
        
        let chatVC = ChatViewController(with: email, id:nil)
        chatVC.isNew = true
        chatVC.title = name
        chatVC.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(chatVC, animated: true)
    }
    
    func setupTable(){
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func fetchConv(){
        //Firebase Work
        
        tableView.isHidden = false
        
    }
    
    func validateAuth() {
        if Auth.auth().currentUser == nil {
            let mainVC = storyboard?.instantiateViewController(identifier: "Main") as! HomeViewController
            let nav = UINavigationController(rootViewController: mainVC)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: false)
        }
    }
}

extension MessageViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        conversations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let conv = conversations[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "messageCell", for: indexPath) as! MessageCell
        
        cell.configure(with: conv)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let conv = conversations[indexPath.row]
        
        openConversation(conversation:conv)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func openConversation(conversation:Conversation){
        let chatVC = ChatViewController(with: conversation.otherEmail, id: conversation.id)
        chatVC.title = conversation.name
        chatVC.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(chatVC, animated: true)
    }
}
