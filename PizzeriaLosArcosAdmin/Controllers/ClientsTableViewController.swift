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
    var userList: [User] = []
    
    let db = Firestore.firestore()

    override func viewDidLoad() {
        super.viewDidLoad()
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
        return userList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.Collections.customerCell, for: indexPath) as UITableViewCell
        cell.textLabel?.text = userList[indexPath.row].phoneNumber
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


