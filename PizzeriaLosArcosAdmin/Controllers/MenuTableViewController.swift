//
//  MenuTableViewController.swift
//  PizzeriaLosArcosAdmin
//
//  Created by Edgar López Enríquez on 28/04/22.
//

import UIKit

class MenuTableViewController: UITableViewController {
    var menu = [K.Texts.PIZZA: K.Texts.PIZZA_TITLE,
                K.Texts.BURGER: K.Texts.BURGER_TITLE, K.Texts.SALAD: K.Texts.SALAD_TITLE,
                K.Texts.PLATILLO: K.Texts.PLATILLO_TITLE, K.Texts.SEA_FOOD: K.Texts.SEA_FOOD_TITLE,
                K.Texts.BREAKFAST: K.Texts.BREAKFAST_TITLE, K.Texts.DRINKS: K.Texts.DRINKS_TITLE,
                K.Texts.DESSERTS: K.Texts.DESSERTS_TITLE, K.Texts.MILKSHAKESICECREAM: K.Texts.MILKSHAKESICECREAM_TITLE,
                K.Texts.KIDS: K.Texts.KIDS_TITLE]
    
    var foodTitle: String?
    var foodType: String?

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.Segues.menuToFood {
            let destinationVC = segue.destination as! FoodListTableViewController
            destinationVC.foodType = foodType
            destinationVC.foodTitle = foodTitle
        }
    }
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menu.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.Collections.menuCell, for: indexPath) as UITableViewCell
        
        let menuArray = Array(menu)
        
        cell.textLabel?.text = menuArray[indexPath.row].value
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.textColor = UIColor(named: K.BrandColors.primaryColor)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let menuArray = Array(menu)
        
        let currMenu = menuArray[indexPath.row]
        
        foodTitle = currMenu.value
        foodType = currMenu.key
        
        self.performSegue(withIdentifier: K.Segues.menuToFood, sender: self)
    }

}
