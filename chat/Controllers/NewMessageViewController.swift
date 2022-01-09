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
    
    var users = [[String:String]] ()
    var results = [SearchResult] ()
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
     func vewDidLayout() {
        super.viewDidLoad()
        noLabel.frame = CGRect(x : 0.0, y : 0.0, width: 200.0, height: 200.0)
    }
    
    @objc func didCancelTapped(){
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension NewMessageViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
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
        
        guard let text = searchBar.text, !text.isEmpty else {
            return
        }
        
        searchBar.resignFirstResponder()
        results.removeAll()
        self.searchUsers(query: text)
    }
    
    func searchUsers(query:String){
        if hasFetced {
            filterUsers(term: query)
        }else {
            DatabaseManager.shared.getAllUsers(completion: { results in
                switch results {
                case .success(let userCollection):
                    self.hasFetced = true
                    self.users = userCollection
                    self.filterUsers(term:"" )
                case .failure(let erorr):
                    print("faild to get users:\(erorr)")
                }
            
            })
        }
        
    }
    
    func filterUsers(term:String){
        guard hasFetced else {
            return
        }
        
        let result : [[String:String]] = self.users.filter({
            guard let name = $0["name"]?.lowercased() else {
                return false
            }
            
            return name.hasPrefix(term.lowercased())
        })
            
        //self.results = result
        updateUI()
    }
    
    func updateUI(){
        if users.isEmpty {
            self.noLabel.isHidden = false
            self.tableView.isHidden = true
        }else {
            self.noLabel.isHidden = true
            self.tableView.isHidden = false
            self.tableView.reloadData()
        }
    }
}

struct SearchResult {
    let name:String
    let email:String
}
