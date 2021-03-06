//
//  InProcessViewController.swift
//  PizzeriaLosArcosAdmin
//
//  Created by Edgar López Enríquez on 29/03/22.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift
import ProgressHUD

class InProcessViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var waitTimeLabel: UILabel!
    @IBOutlet weak var waitTimeSlider: UISlider!
    @IBOutlet weak var onlineServiceSwitch: UISwitch!
    @IBOutlet weak var messageStateServiceLabel: UILabel!
    
    let db = Firestore.firestore()
    
    var ordersList: [Order] = []
    var order: Order?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: K.Collections.orderTableViewCell, bundle: nil), forCellReuseIdentifier: K.Collections.orderCell)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.allowsSelection = false
        
        waitTimeSlider.addTarget(self, action: #selector(onSliderValChanged(slider:event:)), for: .valueChanged)
        
        loadOrders()
        
        checkService()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getWaitTime()
    }
    
    @objc func onSliderValChanged(slider: UISlider, event: UIEvent) {
        if let touchEvent = event.allTouches?.first {
            switch touchEvent.phase {
            case .moved:
                waitTimeLabel.text = String(format: "%.0f minutos", slider.value)
            case .ended:
                ProgressHUD.show()
                self.db.collection(K.Firebase.waitTimeCollection).document(K.Firebase.time).updateData([
                    K.Firebase.time: Int(round(slider.value)),
                ]) { err in
                    ProgressHUD.dismiss()
                    if let err = err {
                        self.alert(title: K.Texts.problemOcurred, message: err.localizedDescription)
                    } else {
                        print("Document successfully updated")
                    }
                }
            default:
                break
            }
        }
    }
    
    func getWaitTime() {
        ProgressHUD.show()
        db.collection(K.Firebase.waitTimeCollection).document(K.Firebase.time).getDocument { (document, error) in
            ProgressHUD.dismiss()
            if let error = error {
                self.alert(title: K.Texts.problemOcurred, message: error.localizedDescription)
            } else {
                if let document = document, document.exists {
                    let data = document.data()
                    if let waitTime = data?[K.Firebase.time] as? Int {
                        DispatchQueue.main.async {
                            self.waitTimeLabel.text = "\(waitTime) minutos"
                            self.waitTimeSlider.setValue(Float(waitTime), animated: true)
                        }
                    }
                } else {
                    self.alert(title: K.Texts.problemOcurred, message: error!.localizedDescription)
                }
            }
        }
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
    
    func loadOrders() {
        ProgressHUD.show()
        db.collection(K.Firebase.ordersCollection).addSnapshotListener { querySnapshot, error in
            ProgressHUD.dismiss()
            self.ordersList = []
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
                            if !order.complete {
                                self.ordersList.append(order)
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
    
    @IBAction func stateSwitchServicePressed(_ sender: UISwitch) {
        if sender.isOn {
            setStateService(true, "Servicio activo.")
        } else {
            self.performSegue(withIdentifier: K.Segues.InProccessToServiceMessage, sender: self)
        }
       
    }
    
    func setStateService(_ state: Bool, _ message: String) {
        ProgressHUD.show()
        self.db.collection(K.Firebase.messageCollection).document(K.Firebase.current).updateData([
            K.Firebase.status: state,
            K.Firebase.message: message
        ]) { err in
            ProgressHUD.dismiss()
            if let err = err {
                self.alert(title: K.Texts.problemOcurred, message: err.localizedDescription)
            } else {
                print("Document successfully updated")
            }
        }
    }
    
    func checkService() {
        ProgressHUD.show()
        db.collection(K.Firebase.messageCollection).document(K.Firebase.current).addSnapshotListener { document, error in
            ProgressHUD.dismiss()
            if let error = error {
                self.alert(title: "¡Ha ocurrido un problema!", message: error.localizedDescription)
            } else {
                if let document = document, document.exists {
                    let data = document.data()
                    if let activeStatus = data?[K.Firebase.status] as? Bool,
                       let messageStatus = data?[K.Firebase.message] as? String {
                        self.onlineServiceSwitch.setOn(activeStatus, animated: true)
                        self.waitTimeSlider.isEnabled = activeStatus
                        if !activeStatus {
                            self.messageStateServiceLabel.text = messageStatus
                            self.waitTimeSlider.tintColor = UIColor(named: K.BrandColors.thirdColor)
                        } else {
                            self.messageStateServiceLabel.text = "Servicio activo."
                            self.waitTimeSlider.tintColor = UIColor(named: K.BrandColors.primaryColor)
                        }
                    }
                } else {
                    self.alert(title: "¡Ha ocurrido un problema!", message: error!.localizedDescription)
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
        if segue.identifier == K.Segues.inProccessToOrderDetails {
            let destinationVC = segue.destination as! OrderDetailsViewController
            destinationVC.order = order
        }
        
        if segue.identifier == K.Segues.InProccessToServiceMessage {
            if let destionationVC = segue.destination as? ServiceMessageTableViewController {
                let controller = destionationVC.popoverPresentationController
                controller?.delegate = self
                destionationVC.delegate = self
                destionationVC.modalPresentationStyle = .popover
            }
            
        }
    }
    
}


//MARK: - PopOverPresentation extension

extension InProcessViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        setAlphaOfBackgroundViews(alpha: 1)
        onlineServiceSwitch.setOn(true, animated: true)
    }
    
    func prepareForPopoverPresentation(_ popoverPresentationController: UIPopoverPresentationController) {
        setAlphaOfBackgroundViews(alpha: 0.7)
    }
    
    func setAlphaOfBackgroundViews(alpha: CGFloat) {
        UIView.animate(withDuration: 0.2) {
            self.view.alpha = alpha;
            self.navigationController?.navigationBar.alpha = alpha;
        }
    }
}

extension InProcessViewController: PassDataDelegate {
    func passData(_ data: String) {
        setStateService(false, data)
        UIView.animate(withDuration: 0.2) {
            self.view.alpha = 1;
            self.navigationController?.navigationBar.alpha = 1;
        }
    }
}

protocol PassDataDelegate {
    func passData(_ data: String)
}


//MARK: - TableView Delegate and DataSource

extension InProcessViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if ordersList.count == 0 {
            tableView.setEmptyView(title: "No hay pedidos en cola", message: "Aquí apareceran los pedidos")
        } else {
            tableView.restore()
        }
        
        return ordersList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.Collections.orderCell, for: indexPath) as! OrderTableViewCell
        
        let currOrder = ordersList[indexPath.row]
        
        cell.folioLabel.text = currOrder.folio
        cell.priceLabel.text = "$\(String(format: "%.2f", ceil(currOrder.totalPrice*100)/100))"
        cell.clientNameLabel.text = currOrder.clientName
        cell.clientPhoneLabel.text = currOrder.client
        cell.statusLabel.text = currOrder.status
        
        let timeEstimatedDelivery = currOrder.dateEstimatedDelivery
        let dateEstimatedDelivery = Date(timeIntervalSince1970: timeEstimatedDelivery)
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "h:mm a"
        dateFormatter.amSymbol = "AM"
        dateFormatter.pmSymbol = "PM"
        
        cell.timeEstimatedDelivery.text = "\(dateFormatter.string(from: dateEstimatedDelivery))"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let index = indexPath.row
        let currOrder = ordersList[index]
        
        let identifier = "\(index)" as NSString
        
        return UIContextMenuConfiguration(
            identifier: identifier,
            previewProvider: nil) { _ in
                
                var title = "Cambiar estado a En proceso"
                var image = UIImage(named: "kitchen")
                
                if currOrder.status == "Pedido" {
                    title = "Cambiar estado a En proceso"
                    image = UIImage(named: "kitchen")
                } else if currOrder.status == "En proceso" {
                    title = "Cambiar estado a Listo"
                    image = UIImage(named: "check")
                } else if currOrder.status == "Listo" {
                    title = "Cambiar estado a Entregado"
                    image = UIImage(named: "delivered")
                }
                
                let changeStatus = UIAction(title: title,
                                            image: image,
                                            identifier: nil
                ) { _ in
                    if currOrder.status == "Pedido" {
                        self.changeStateToInProcess(currOrder, "En proceso", Date().timeIntervalSince1970)
                    } else if currOrder.status == "En proceso" {
                        self.getUserToken(currOrder.client) { token in
                            let sender = PushNotificationSender()
                            sender.sendPushNotification(to: token, title: "¡Tu pedido está listo!", body: "Recuarda pasar por él a la sucursal del Gomez Morín", folio: currOrder.folio, imagenURL: nil, options: nil)
                            self.changeStateToFinished(currOrder, "Listo", Date().timeIntervalSince1970)
                        }
                    } else if currOrder.status == "Listo" {
                        self.changeStateToDelivered(currOrder, "Entregado", Date().timeIntervalSince1970)
                    }
                }
                
                
                let printOrder = UIAction(title: "Imprimir",
                                          image: UIImage(named: "print"),
                                          identifier: nil
                ) { _ in
                    print("Edit Image Action")
                }
                
                let showDetails = UIAction(title: "Ver detalles",
                                           image: UIImage(named: "more"),
                                           identifier: nil
                ) { _ in
                    self.order = currOrder
                    self.performSegue(withIdentifier: K.Segues.inProccessToOrderDetails, sender: self)
                }
                
                let origImage = UIImage(named: "delete")
                let tintedImage = origImage?.withRenderingMode(.alwaysTemplate)
                
                let removeAction = UIAction(title: "Cancelar pedido",
                                            image: tintedImage,
                                            identifier: nil,
                                            discoverabilityTitle: nil,
                                            attributes: .destructive,
                                            handler: { _ in
                    self.getUserToken(currOrder.client) { token in
                        let sender = PushNotificationSender()
                        sender.sendPushNotification(to: token, title: "Tu pedido ha sido cancelado correctamente", body: "Esperamos tu nuevo pedido", folio: currOrder.folio, imagenURL: nil, options: nil)
                        self.changeStateToCanceled(currOrder, "Cancelado", Date().timeIntervalSince1970)
                    }
                })
                
                if currOrder.status == "Entregado" || currOrder.status == "Cancelado" {
                    return UIMenu(title: "", image: nil, children: [printOrder, showDetails])
                } else {
                    return UIMenu(title: "", image: nil, children: [changeStatus, printOrder, showDetails, removeAction])
                }
            }
    }
    
    func tableView(_ tableView: UITableView, previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        guard
            let identifier = configuration.identifier as? String,
            let index = Int(identifier),
            
                let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0))
                as? OrderTableViewCell
        else {
            return nil
        }
        
        return UITargetedPreview(view: cell.viewCell)
    }
    
}
