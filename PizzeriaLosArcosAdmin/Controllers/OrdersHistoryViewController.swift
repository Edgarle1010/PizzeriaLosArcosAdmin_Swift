//
//  OrdersHistoryViewController.swift
//  PizzeriaLosArcosAdmin
//
//  Created by Edgar López Enríquez on 21/04/22.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift
import ProgressHUD

class OrdersHistoryViewController: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    let db = Firestore.firestore()
    
    var user: User?
    var orderList: [Order] = []
    var order: Order?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let user = user else {
            return
        }

        titleLabel.text = "Historial de pedidos de \(user.name)"
        
        loadOrders(user)
    }
    
    func loadOrders(_ user: User) {
        tableView.register(UINib(nibName: K.Collections.orderTableViewCell, bundle: nil), forCellReuseIdentifier: K.Collections.orderCell)
        tableView.rowHeight = UITableView.automaticDimension
        
        ProgressHUD.show()
        db.collection(K.Firebase.ordersCollection)
            .whereField(K.Firebase.client, isEqualTo: user.phoneNumber)
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
    
    func alert(title: String?, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: K.Texts.ok, style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        return
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.Segues.ordersHistoryToOrderDetails {
            let destinationVC = segue.destination as! OrderDetailsViewController
            destinationVC.order = order
        }
    }

}

extension OrdersHistoryViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        orderList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.Collections.orderCell, for: indexPath) as! OrderTableViewCell
        
        let currOrder = orderList[indexPath.row]
        
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
        performSegue(withIdentifier: K.Segues.ordersHistoryToOrderDetails, sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
}
