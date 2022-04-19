//
//  ServiceMessageTableViewController.swift
//  PizzeriaLosArcosAdmin
//
//  Created by Edgar López Enríquez on 18/04/22.
//

import UIKit
import Firebase
import ProgressHUD

class ServiceMessageTableViewController: UITableViewController {
    var posts: [String]?
    var delegate: PassDataDelegate?
    
    let db = Firestore.firestore()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        ProgressHUD.show()
        db.collection(K.Firebase.messageCollection).document(K.Firebase.options).getDocument { document, error in
            ProgressHUD.dismiss()
            if let document = document, document.exists {
                let data = document.data()
                self.posts = data?[K.Firebase.posts] as? [String]
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
            } else {
                self.alert(title: K.Texts.problemOcurred, message: error!.localizedDescription)
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
        return posts?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as UITableViewCell
        cell.textLabel?.text = posts?[indexPath.row]
        cell.textLabel?.numberOfLines = 0
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        delegate?.passData(posts![indexPath.row])
        self.dismiss(animated: true, completion: nil)
    }
    
}
