//
//  FullOrderHistoryViewController.swift
//  PizzeriaLosArcosAdmin
//
//  Created by Edgar López Enríquez on 26/04/22.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift
import ProgressHUD

class FullOrderHistoryViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    lazy var searchController: UISearchController = {
        let s = UISearchController(searchResultsController: nil)
        s.searchResultsUpdater = self
        
        s.obscuresBackgroundDuringPresentation = false
        s.searchBar.placeholder = "Buscar ordenes..."
        s.searchBar.sizeToFit()
        s.searchBar.searchBarStyle = .prominent
        
        s.searchBar.scopeButtonTitles = ["Folio", "Cliente", "Estado"]
        
        s.searchBar.delegate = self
        
        return s
    }()
    var scope: String?
    
    let db = Firestore.firestore()
    
    var orderList: [Order] = []
    var filteredOrders: [Order] = []
    var order: Order?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let standardAppearance = UINavigationBarAppearance()

        standardAppearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(named: K.BrandColors.primaryColor)!]

        standardAppearance.configureWithOpaqueBackground()
        standardAppearance.backgroundColor = UIColor(named: K.BrandColors.secundaryColor)

        self.navigationController?.navigationBar.standardAppearance = standardAppearance
        self.navigationController?.navigationBar.scrollEdgeAppearance = standardAppearance
        
        navigationItem.searchController = searchController
    
        loadOrders()
        
    }
    
    func loadOrders() {
        tableView.register(UINib(nibName: K.Collections.orderTableViewCell, bundle: nil), forCellReuseIdentifier: K.Collections.orderCell)
        tableView.rowHeight = UITableView.automaticDimension
        
        ProgressHUD.show()
        db.collection(K.Firebase.ordersCollection)
            .getDocuments { querySnapshot, error in
                ProgressHUD.dismiss()
                self.orderList.removeAll()
                if let error = error {
                    self.alert(title: K.Texts.problemOcurred, message: error.localizedDescription)
                } else {
                    if let documents = querySnapshot?.documents {
                        for doc in documents {
                            let result = Result {
                                try doc.data(as: Order.self)
                            }
                            switch result {
                            case .success(let order):
                                self.orderList.append(order)
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
    
    func filterContentForSearchText(searchText: String, scope: String) {
        filteredOrders = orderList.filter({ (order: Order) -> Bool in
            let doesCategoryMatch = (scope == "Folio") || (scope == "Cliente") || (scope == "Estado")
            
            self.scope = scope
            
            if isSearchBarEmpty() {
                return doesCategoryMatch
            } else {
                if scope == "Folio" {
                    return doesCategoryMatch && order.folio.lowercased().contains(searchText.lowercased())
                } else if scope == "Cliente" {
                    return doesCategoryMatch && order.client.lowercased().contains(searchText.lowercased())
                } else {
                    return doesCategoryMatch && order.status.lowercased().contains(searchText.lowercased())
                }
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
        alert.addAction(UIAlertAction(title: K.Texts.ok, style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        return
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.Segues.fullOrdersHistoryToOrderDetails {
            let destinationVC = segue.destination as! OrderDetailsViewController
            destinationVC.order = order
        }
    }
}


//MARK: - UITableView delegate & data source

extension FullOrderHistoryViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if orderList.count == 0 {
            tableView.setEmptyView(title: "No hay ningún pedido", message: "Aquí se mostraron los pedidos que haga cualquiera de los clientes")
        } else {
            tableView.restore()
        }
        
        if isFiltering() { return filteredOrders.count }
        
        return orderList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.Collections.orderCell, for: indexPath) as! OrderTableViewCell
        
        var currOrder: Order
        
        if isFiltering() {
            currOrder = filteredOrders[indexPath.row]
        } else {
            currOrder = orderList[indexPath.row]
        }
        
        let timeRequest = currOrder.dateRequest
        let dateRequest = Date(timeIntervalSince1970: timeRequest)
        
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.timeZone = TimeZone.current
        dateFormatterGet.locale = NSLocale.current
        dateFormatterGet.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        cell.folioLabel.text = currOrder.folio
        cell.priceLabel.text = "$\(String(format: "%.2f", ceil(currOrder.totalPrice*100)/100))"
        cell.clientNameLabel.isHidden = true
        cell.clientPhoneLabel.text = currOrder.client
        cell.statusLabel.text = currOrder.status
        cell.staticEstimatedDelivery.isHidden = true
        cell.timeEstimatedDelivery.text = "\(dateFormatterGet.string(from: dateRequest))"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        order = orderList[indexPath.row]
        performSegue(withIdentifier: K.Segues.fullOrdersHistoryToOrderDetails, sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}


//MARK: - UISearchController

extension FullOrderHistoryViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchText: searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
    }
}

extension FullOrderHistoryViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        
        filterContentForSearchText(searchText: searchController.searchBar.text!, scope: scope)
    }
}
