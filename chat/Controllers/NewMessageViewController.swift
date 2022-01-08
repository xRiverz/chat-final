//
//  NewMessageViewController.swift
//  chat
//
//  Created by administrator on 06/01/2022.
//

import UIKit
import JGProgressHUD


class NewMessageViewController: UIViewController {
    @IBOutlet weak var noLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    let spinner = JGProgressHUD(style: .dark)
    
    var completion : ((SearchResult) -> (Void))?
    
    var users : [[String:String]] = [] // used to fetch users from DB
    var results : [SearchResult] = [] // filtered users based on search and used for table
    var hasFetced = false
    
    private var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search for Users..."
        return searchBar
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
        navigationController?.navigationBar.topItem?.titleView = searchBar
        navigationItem.rightBarButtonItem = UIBarButtonItem(title:"Cancel", style:.done, target: self, action: #selector(didCancelTapped))
        
        searchBar.becomeFirstResponder()
        
        // Do any additional setup after loading the view.
    }
    
    @objc func didCancelTapped(){
        dismiss(animated: true, completion: nil)
    }
    
}

extension NewMessageViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
                
        cell.textLabel?.text = results[indexPath.row].name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let targetUser = results[indexPath.row]
        dismiss(animated: true, completion: { [weak self] in
            self?.completion?(targetUser)
        })
    }
}

extension NewMessageViewController : UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        guard let text = searchBar.text, !text.replacingOccurrences(of: " ", with: "").isEmpty else {
            return
        }
        
        searchBar.resignFirstResponder()
        
        spinner.show(in: view)
        
        searchUsers(query: text)
    }
    
    func searchUsers(query:String){
        if hasFetced {
            filterUsers(term: query)
        }else {
            DatabaseManager.shared.getAllUsers(completion: {
                [weak self] result in
                switch result {
                case .success(let users):
                    self?.users = users
                    self?.hasFetced = true
                    self?.filterUsers(term: query)
                case .failure(let error):
                    print(error.localizedDescription)
                }
            })
        }
        
    }
    
    func filterUsers(term:String){
        guard hasFetced else {
            return
        }
        
        let results : [SearchResult] = self.users.filter({
            guard let name = $0["name"]?.lowercased() else {
                return false
            }
            
            return name.hasPrefix(term.lowercased())
        }).compactMap({
            
            guard let name = $0["name"], let email = $0["email"] else {
                return nil
            }
            
            return SearchResult(name: name, email: email)
        })
        
        spinner.dismiss()
                
        self.results = results
        
        updateUI()
    }
    
    func updateUI(){
        if results.isEmpty {
            noLabel.isHidden = false
            tableView.isHidden = true
        }else {
            noLabel.isHidden = true
            tableView.isHidden = false
            tableView.reloadData()
        }
    }
}

struct SearchResult {
    let name:String
    let email:String
}
