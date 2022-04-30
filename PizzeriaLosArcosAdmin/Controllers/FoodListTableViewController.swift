//
//  FoodListTableViewController.swift
//  PizzeriaLosArcosAdmin
//
//  Created by Edgar López Enríquez on 28/04/22.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift
import ProgressHUD

class FoodListTableViewController: UITableViewController {
    
    var foodType: String?
    var foodTitle: String?
    
    var foodList: [Food] = []
    var food: Food?
    
    let db = Firestore.firestore()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let foodType = foodType, let foodTitle = foodTitle else {
            return
        }
        
        navigationItem.title = foodTitle
        
        ProgressHUD.show()
        db.collection(K.Firebase.foodCollection).order(by: K.Firebase.listPosition)
            .getDocuments { (querySnapshot, error) in
                ProgressHUD.dismiss()
                if let error = error {
                    self.alert(title: "¡Ha ocurrido un problema!", message: error.localizedDescription)
                } else {
                    if let documents = querySnapshot?.documents {
                        for doc in documents {
                            let result = Result {
                                try doc.data(as: Food.self)
                            }
                            switch result {
                            case .success(let food):
                                if (food.id.contains(foodType)) {
                                    self.foodList.append(food)
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
    
    func alert(title: String?, message: String) {
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
        return foodList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.Collections.foodCell, for: indexPath) as UITableViewCell
        
        food = foodList[indexPath.row]
        
        cell.textLabel?.text = food?.title
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.textColor = UIColor(named: K.BrandColors.primaryColor)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedFood = foodList[indexPath.row]
        
        if let splitVC = self.splitViewController, let detailVC = splitVC.viewControllers[1] as? FoodDetailsViewController {
            detailVC.food = selectedFood
            detailVC.foodType = foodType
        }
    }

}
