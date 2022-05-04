//
//  ExtraIngredientsListViewController.swift
//  PizzeriaLosArcosAdmin
//
//  Created by Edgar López Enríquez on 03/05/22.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift
import ProgressHUD

class ExtraIngredientsListViewController: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    let db = Firestore.firestore()
    
    var foodType: String?
    var extraIngredientList: [ExtraIngredient] = []
    var extraIngredient: ExtraIngredient?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let foodType = foodType else {
            return
        }

        loadExtraIngredientsList(foodType)
    }
    
    func loadExtraIngredientsList(_ foodType: String) {
        ProgressHUD.show()
        db.collection(K.Firebase.extraIngredientsCollection).order(by: K.Firebase.listPosition)
            .getDocuments { (querySnapshot, error) in
                ProgressHUD.dismiss()
                if let error = error {
                    self.alert(title: "¡Ha ocurrido un problema!", message: error.localizedDescription)
                } else {
                    if let documents = querySnapshot?.documents {
                        for doc in documents {
                            let result = Result {
                                try doc.data(as: ExtraIngredient.self)
                                }
                                switch result {
                                case .success(let extraIngredient):
                                    if extraIngredient.food.contains(foodType) {
                                        self.extraIngredientList.append(extraIngredient)
                                    }
                                case .failure(let error):
                                    print("Error decoding food: \(error)")
                                }
                        }
                        
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    }
                }
            }
    }
    
    func alert(title: String?, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: K.Texts.ok, style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        return
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.Segues.extraIngredientsToExtraIngredientsDetails {
            let destinationVC = segue.destination as! ExtraIngredientDetailsViewController
            destinationVC.extraIngredient = extraIngredient
        }
    }

}


//MARK: - table view delegate and data source

extension ExtraIngredientsListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return extraIngredientList.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.Collections.extraIngredientListCell, for: indexPath) as UITableViewCell
        
        cell.textLabel?.text = extraIngredientList[indexPath.row].title
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.textColor = UIColor(named: K.BrandColors.primaryColor)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        extraIngredient = extraIngredientList[indexPath.row]
        
        self.performSegue(withIdentifier: K.Segues.extraIngredientsToExtraIngredientsDetails, sender: self)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
