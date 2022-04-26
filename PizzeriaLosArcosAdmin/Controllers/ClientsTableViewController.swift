//
//  ClientsTableViewController.swift
//  PizzeriaLosArcosAdmin
//
//  Created by Edgar López Enríquez on 19/04/22.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift
import ProgressHUD

class ClientsTableViewController: UITableViewController {
    lazy var searchController: UISearchController = {
        let s = UISearchController(searchResultsController: nil)
        s.searchResultsUpdater = self
        
        s.obscuresBackgroundDuringPresentation = false
        s.searchBar.placeholder = "Buscar usuarios..."
        s.searchBar.sizeToFit()
        s.searchBar.searchBarStyle = .prominent
        
        s.searchBar.scopeButtonTitles = ["All", "Celular", "Nombre", "Apellido"]
        
        s.searchBar.delegate = self
        
        return s
    }()
    
    var userList: [User] = []
    var filteredUsers: [User] = []
    
    let db = Firestore.firestore()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.searchController = searchController
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadUsers()
    }
    
    func loadUsers() {
        ProgressHUD.show()
        db.collection(K.Firebase.userCollection).getDocuments { querySnapshot, error in
            ProgressHUD.dismiss()
            self.userList = []
            if let error = error {
                self.alert(title: K.Texts.problemOcurred, message: error.localizedDescription)
            } else {
                if let documents = querySnapshot?.documents {
                    for doc in documents {
                        let result = Result {
                            try doc.data(as: User.self)
                        }
                        switch result {
                        case .success(let user):
                            self.userList.append(user)
                        case .failure(let error):
                            print("Error decoding food: \(error)")
                        }
                    }
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                        let indexPath = IndexPath(row: 0, section: 0)
                        self.tableView.selectRow(at: indexPath, animated: true, scrollPosition: .bottom)
                        self.tableView.delegate?.tableView!(self.tableView, didSelectRowAt: indexPath)
                    }
                }
            }
        }
    }
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        filteredUsers = userList.filter({ (user: User) -> Bool in
            let doesCategoryMatch = (scope == "All") || (user.phoneNumber == scope)
            
            if isSearchBarEmpty() {
                return doesCategoryMatch
            } else {
                return doesCategoryMatch && user.phoneNumber.lowercased().contains(searchText.lowercased())
            }
        })
        
        tableView.reloadData()
    }
    
    func isSearchBarEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func isFiltering() -> Bool {
        let searchBarScopeIsFiltering = searchController.searchBar.selectedScopeButtonIndex != 0
        return searchController.isActive && (!isSearchBarEmpty() || searchBarScopeIsFiltering)
    }
    
    func alert(title: String?, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        return
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() { return filteredUsers.count }
        return userList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.Collections.customerCell, for: indexPath) as UITableViewCell
        
        let currentUser: User
        
        if isFiltering() {
            currentUser = filteredUsers[indexPath.row]
        } else {
            currentUser = userList[indexPath.row]
        }
        
        cell.textLabel?.text = currentUser.phoneNumber
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.textColor = UIColor(named: K.BrandColors.primaryColor)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedUser = userList[indexPath.row]
        
        if let splitVC = self.splitViewController, let detailVC = splitVC.viewControllers[1] as? ClientDetailsViewController {
            detailVC.user = selectedUser
        }
    }

}


//MARK: - UISearchController

extension ClientsTableViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchText: searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
    }
}

extension ClientsTableViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        
        filterContentForSearchText(searchText: searchController.searchBar.text!, scope: scope)
    }
}


