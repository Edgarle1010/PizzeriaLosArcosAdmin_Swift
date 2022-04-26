//
//  OrderDetailsViewController.swift
//  PizzeriaLosArcosAdmin
//
//  Created by Edgar López Enríquez on 07/04/22.
//

import UIKit
import Firebase
import ProgressHUD
import MapKit

class OrderDetailsViewController: UIViewController {
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var moreButton: UIButton!
    
    @IBOutlet weak var folioLabel: UILabel!
    @IBOutlet weak var clientLabel: UILabel!
    @IBOutlet weak var clientNameLabel: UILabel!
    @IBOutlet weak var ubicationLabel: UILabel!
    @IBOutlet weak var orderCompleteLabel: UILabel!
    
    @IBOutlet weak var dateView: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var dateRequestLabel: UILabel!
    @IBOutlet weak var dateProcessedLabel: UILabel!
    @IBOutlet weak var dateFinishedLabel: UILabel!
    @IBOutlet weak var titleDateCanceledLabel: UILabel!
    @IBOutlet weak var dateDeliveredLabel: UILabel!
    
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var totalView: UIView!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    let db = Firestore.firestore()
    
    var order: Order?
    
    var items: [Item] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(OrderDetailsViewController.tapFunction))
        ubicationLabel.isUserInteractionEnabled = true
        ubicationLabel.addGestureRecognizer(tap)
        
        loadViews()
        
        tableView.register(UINib(nibName: K.Collections.itemTableViewCell, bundle: nil), forCellReuseIdentifier: K.Collections.itemCell)
        tableView.rowHeight = UITableView.automaticDimension
        
        guard let order = order else {
            return
        }
        
        loadOrderDetails(order)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    @IBAction func backPressed(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction func tapFunction(sender: UITapGestureRecognizer) {
        guard let label = sender.view as? UILabel else { return }
        if label.text != K.Texts.locationNotProveided {
            self.performSegue(withIdentifier: K.Segues.orderDetailsToUbicationMap, sender: self)
        }
    }
    
    func loadViews() {
        let backButtonImage = UIImage(named: K.Images.back)
        let backButtonTintedImage = backButtonImage?.withRenderingMode(.alwaysTemplate)
        backButton.setImage(backButtonTintedImage, for: .normal)
        backButton.tintColor = UIColor.init(named: K.BrandColors.primaryColor)
        
        let printButtonImage = UIImage(named: K.Images.more)
        let printButtonTintedImage = printButtonImage?.withRenderingMode(.alwaysTemplate)
        moreButton.setImage(printButtonTintedImage, for: .normal)
        moreButton.tintColor = UIColor.init(named: K.BrandColors.primaryColor)
    }
    
    func loadOrderDetails(_ order: Order) {
        ProgressHUD.show()
        db.collection(K.Firebase.ordersCollection)
            .whereField(K.Firebase.folio, isEqualTo: order.folio)
            .addSnapshotListener { querySnapshot, error in
                ProgressHUD.dismiss()
                self.items = []
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
                                self.folioLabel.text = order.folio
                                self.clientLabel.text = order.client
                                self.clientNameLabel.text = order.clientName
                                self.ubicationLabel.text = order.location
                                self.orderCompleteLabel.text = order.complete.description
                                
                                let timeRequest = order.dateRequest
                                let timeProcessed = order.dateProcessed ?? 0.0
                                let timeFinished = order.dateFinished ?? 0.0
                                let timeDelivered = order.dateDelivered ?? 0.0
                                let timeCanceled = order.dateCanceled ?? 0.0
                                
                                let dateRequest = Date(timeIntervalSince1970: timeRequest)
                                let dateProcessed = Date(timeIntervalSince1970: timeProcessed)
                                let dateFinished = Date(timeIntervalSince1970: timeFinished)
                                let dateDelivered = Date(timeIntervalSince1970: timeDelivered)
                                let dateCenceled = Date(timeIntervalSince1970: timeCanceled)
                                
                                let dateFormatterGet = DateFormatter()
                                dateFormatterGet.timeZone = TimeZone.current
                                dateFormatterGet.locale = NSLocale.current
                                dateFormatterGet.dateFormat = "yyyy-MM-dd HH:mm:ss"
                                
                                let dateFormatter = DateFormatter()
                                dateFormatter.timeZone = TimeZone.current
                                dateFormatter.locale = NSLocale.current
                                dateFormatter.dateFormat = "h:mm a"
                                dateFormatter.amSymbol = "AM"
                                dateFormatter.pmSymbol = "PM"
                                
                                self.dateLabel.text = "Fecha del pedido: \(dateFormatterGet.string(from: dateRequest))"
                                self.dateRequestLabel.text = "\(dateFormatter.string(from: dateRequest))"
                                if timeProcessed != 0.0 {
                                    self.dateProcessedLabel.text = "\(dateFormatter.string(from: dateProcessed))"
                                } else {
                                    self.dateProcessedLabel.text = ""
                                }
                                if timeFinished != 0.0 {
                                    self.dateFinishedLabel.text = "\(dateFormatter.string(from: dateFinished))"
                                } else {
                                    self.dateFinishedLabel.text = ""
                                }
                                if timeDelivered != 0.0 {
                                    self.dateDeliveredLabel.text = "\(dateFormatter.string(from: dateDelivered))"
                                } else {
                                    self.dateDeliveredLabel.text = ""
                                }
                                if timeCanceled != 0.0 {
                                    self.titleDateCanceledLabel.text = "Hora de cancelación:"
                                    self.dateDeliveredLabel.text = "\(dateFormatter.string(from: dateCenceled))"
                                }
                                
                                self.statusLabel.text = order.status
                                self.totalLabel.text = "Total: $\(String(format: "%.2f", ceil((order.totalPrice)*100)/100))"
                                self.items = Array(order.itemList)
                                
                                self.setMenuMore(order)
                                
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
    
    func setMenuMore(_ order: Order) {
        var title = "Cambiar estado a En proceso"
        var image = UIImage(named: "kitchen")
        
        if order.status == "Pedido" {
            title = "Cambiar estado a En proceso"
            image = UIImage(named: "kitchen")
        } else if order.status == "En proceso" {
            title = "Cambiar estado a Listo"
            image = UIImage(named: "check")
        } else if order.status == "Listo" {
            title = "Cambiar estado a Entregado"
            image = UIImage(named: "delivered")
        }
        
        let changeStatus = UIAction(title: title,
                                    image: image,
                                    identifier: nil
        ) { _ in
            if order.status == "Pedido" {
                self.changeStateToInProcess(order, "En proceso", Date().timeIntervalSince1970)
            } else if order.status == "En proceso" {
                self.getUserToken(order.client) { token in
                    let sender = PushNotificationSender()
                    sender.sendPushNotification(to: token, title: "¡Tu pedido está listo!", body: "Gracias por tu compra", folio: order.folio, imagenURL: nil, options: nil)
                    self.changeStateToFinished(order, "Listo", Date().timeIntervalSince1970)
                }
            } else if order.status == "Listo" {
                self.changeStateToDelivered(order, "Entregado", Date().timeIntervalSince1970)
            }
        }
        
        let printOrder = UIAction(title: "Imprimir",
                                  image: UIImage(named: "print"),
                                  identifier: nil
        ) { _ in
            print("Edit Image Action")
        }
        
        
        let origImage = UIImage(named: "delete")
        let tintedImage = origImage?.withRenderingMode(.alwaysTemplate)
        
        let removeAction = UIAction(title: "Cancelar pedido",
                                    image: tintedImage,
                                    identifier: nil,
                                    discoverabilityTitle: nil,
                                    attributes: .destructive,
                                    handler: { _ in
            self.getUserToken(order.client) { token in
                let sender = PushNotificationSender()
                sender.sendPushNotification(to: token, title: "¡Tu pedido ha sido cancelado correctamente", body: "Esperamos tu nuevo pedido", folio: order.folio, imagenURL: nil, options: nil)
                self.changeStateToCanceled(order, "Cancelado", Date().timeIntervalSince1970)
            }
        })
        
        var menu = UIMenu(title: "", options: .displayInline, children: [changeStatus , printOrder , removeAction])
        if order.status == "Entregado" || order.status == "Cancelado" {
            menu = UIMenu(title: "", options: .displayInline, children: [printOrder])
        }
        
        moreButton.menu = menu
        moreButton.showsMenuAsPrimaryAction = true
    }
    
    func getUserToken(_ userId: String, completion: @escaping (String) -> Void) {
        ProgressHUD.show()
        db.collection(K.Firebase.userCollection)
            .whereField(K.Firebase.phoneNumberField, isEqualTo: userId)
            .getDocuments { querySnapshot, error in
                ProgressHUD.dismiss()
                if let error = error {
                    self.alert(title: K.Texts.problemOcurred, message: error.localizedDescription)
                } else {
                    if let documents = querySnapshot?.documents {
                        if documents.count != 0 {
                            for doc in documents {
                                let data = doc.data()
                                if let token = data[K.Firebase.fcmToken] as? String {
                                    completion(token)
                                }
                            }
                        } else {
                            self.alert(title: "¡Ha ocurrido un problema!", message: "No hay ningún usuario registrado con este número")
                        }
                    }
                }
            }
    }
    
    func changeStateToInProcess(_ order: Order, _ status: String, _ date: Double) {
        ProgressHUD.show()
        self.db.collection(K.Firebase.ordersCollection).document(order.folio).updateData([
            K.Firebase.status: status,
            K.Firebase.dateProcessed: date
        ]) { err in
            ProgressHUD.dismiss()
            if let err = err {
                self.alert(title: K.Texts.problemOcurred, message: err.localizedDescription)
            } else {
                print("Document successfully updated")
            }
        }
    }
    
    func changeStateToFinished(_ order: Order, _ status: String, _ date: Double) {
        ProgressHUD.show()
        self.db.collection(K.Firebase.ordersCollection).document(order.folio).updateData([
            K.Firebase.status: status,
            K.Firebase.dateFinished: date
        ]) { err in
            ProgressHUD.dismiss()
            if let err = err {
                self.alert(title: K.Texts.problemOcurred, message: err.localizedDescription)
            } else {
                print("Document successfully updated")
            }
        }
    }
    
    func changeStateToDelivered(_ order: Order, _ status: String, _ date: Double) {
        ProgressHUD.show()
        self.db.collection(K.Firebase.ordersCollection).document(order.folio).updateData([
            K.Firebase.status: status,
            K.Firebase.dateDelivered: date,
            K.Firebase.complete: true
        ]) { err in
            ProgressHUD.dismiss()
            if let err = err {
                self.alert(title: K.Texts.problemOcurred, message: err.localizedDescription)
            } else {
                print("Document successfully updated")
            }
        }
    }
    
    func changeStateToCanceled(_ order: Order, _ status: String, _ date: Double) {
        ProgressHUD.show()
        self.db.collection(K.Firebase.ordersCollection).document(order.folio).updateData([
            K.Firebase.status: status,
            K.Firebase.dateCanceled: date,
            K.Firebase.complete: true
        ]) {
            err in
            ProgressHUD.dismiss()
            if let err = err {
                self.alert(title: K.Texts.problemOcurred, message: err.localizedDescription)
            } else {
                print("Document successfully updated")
            }
        }
    }
    
    func alert(title: String?, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: K.Texts.ok, style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        return
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.Segues.orderDetailsToUbicationMap {
            let destinationVC = segue.destination as! UbicationMapViewController
            if let latitude = Double(order!.location.before(first: ",")),
               let longitude = Double(order!.location.after(first: ",").trimmingCharacters(in: .whitespaces)) {
                destinationVC.latitude = latitude
                destinationVC.longitude = longitude
            }
        }
    }
    
}


// MARK: - UITableViewDelagete && DataSource

extension OrderDetailsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.Collections.itemCell, for: indexPath) as! ItemTableViewCell
        let item = items[indexPath.row]
        let id = item.id
        let title = item.title
        if id.contains(K.Texts.BURGER)
            || id.contains(K.Texts.SALAD)
            || id.contains(K.Texts.PLATILLO)
            || id.contains(K.Texts.BREAKFAST)
            || id.contains(K.Texts.DRINKS) {
            if title.contains("naranja")
                || title.contains("Limonada")
                || title.contains("Chocolate") {
                cell.titleLabel.text = "\(item.title) | \(item.size)"
            } else {
                cell.titleLabel.text = item.title
            }
        } else if id.contains(K.Texts.DESSERTS)
                    || id.contains(K.Texts.MILKSHAKE_ID)
                    || id.contains(K.Texts.KIDS) {
            cell.titleLabel.text = item.title
        } else {
            cell.titleLabel.text = "\(item.title) | \(item.size)"
        }
        
        if item.extraIngredientList.isEmpty {
            cell.extraIngredientView.isHidden = true
        } else {
            cell.extraIngredientsLabel.text = item.extraIngredientList.map {($0["title"] as? String) ?? nil}.compactMap({$0}).joined(separator: "\n")
        }
        
        if let comments = item.comments {
            if !comments.isEmpty {
                cell.commentsLabel.text = comments
            } else {
                cell.commentsView.isHidden = true
            }
        }
        
        cell.amountLabel.text = String(item.amount)
        cell.totalLabel.text = "$\(String(format: "%.2f", ceil(item.price*100)/100))"
        
        
        return cell
    }
    
}
