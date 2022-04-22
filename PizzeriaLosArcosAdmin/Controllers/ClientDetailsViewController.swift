//
//  ClientDetailsViewController.swift
//  PizzeriaLosArcosAdmin
//
//  Created by Edgar López Enríquez on 19/04/22.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift
import ProgressHUD

class ClientDetailsViewController: UIViewController {
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var lastNameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var streaksLabel: UILabel!
    @IBOutlet weak var ordersCompletedLabel: UILabel!
    @IBOutlet weak var ordersCanceled: UILabel!
    @IBOutlet weak var totalConsumedLabel: UILabel!
    
    let db = Firestore.firestore()
    var listener: ListenerRegistration?
    
    var user: User? {
        didSet {
            if let listener = listener {
                listener.remove()
            }
            loadUserData(user!)
        }
    }
    var orderList: [Order] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let printButtonImage = UIImage(named: K.Images.more)
        let printButtonTintedImage = printButtonImage?.withRenderingMode(.alwaysTemplate)
        moreButton.setImage(printButtonTintedImage, for: .normal)
        moreButton.tintColor = UIColor.init(named: K.BrandColors.primaryColor)
    }
    
    private func refreshUI(_ user: User) {
        loadViewIfNeeded()
        phoneNumberLabel.text = user.phoneNumber
        nameLabel.text = user.name
        lastNameLabel.text = user.lastName
        emailLabel.text = user.email
        if !user.isBaned {
            statusLabel.text = "Activa"
        } else {
            statusLabel.text = "Suspendida"
        }
        streaksLabel.text = "\(user.streaks)"
        
        loadExtraInformation(user)
        
        setMenuMore(user)
    }
    
    func loadUserData(_ user: User) {
        ProgressHUD.show()
        listener = db.collection(K.Firebase.userCollection).document(user.userId)
            .addSnapshotListener { querySnapshot, error in
                ProgressHUD.dismiss()
                if let error = error {
                    self.alert(title: K.Texts.problemOcurred, message: error.localizedDescription)
                } else {
                    let result = Result {
                        try querySnapshot?.data(as: User.self)
                    }
                    switch result {
                    case .success(let user):
                        DispatchQueue.main.async {
                            self.refreshUI(user!)
                        }
                    case .failure(let error):
                        print("Error decoding food: \(error)")
                    }
                }
            }
    }
    
    func loadExtraInformation(_ user: User) {
        ProgressHUD.show()
        db.collection(K.Firebase.ordersCollection)
            .whereField(K.Firebase.client, isEqualTo: user.phoneNumber)
            .addSnapshotListener { querySnapshot, error in
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
                                if order.complete {
                                    self.orderList.append(order)
                                }
                            case .failure(let error):
                                print("Error decoding food: \(error)")
                            }
                        }
                        
                        DispatchQueue.main.async {
                            let total = self.orderList.map({$0.totalPrice}).reduce(0, +)
                            self.totalConsumedLabel.text = "$\(String(format: "%.2f", ceil((total)*100)/100))"
                            
                            var ordersCompleted = 0
                            for order in self.orderList {
                                if order.complete {
                                    ordersCompleted += 1
                                }
                            }
                            self.ordersCompletedLabel.text = "\(ordersCompleted)"
                            self.ordersCanceled.text = "0"
                        }
                    }
                }
            }
    }
    
    func setMenuMore(_ user: User) {
        
        let ordersHistory = UIAction(title: "Historial de pedidos",
                                    image: UIImage(named: K.Images.historyIcon),
                                    identifier: nil
        ) { _ in
            self.performSegue(withIdentifier: K.Segues.clientDetailsToOrdersHistory, sender: self)
        }
        
        let addMissing = UIAction(title: "Añadir falta",
                                  image: UIImage(named: K.Images.faul),
                                  identifier: nil
        ) { _ in
            
        }
        
        
        let origImage = UIImage(named: "ban")
        let tintedImage = origImage?.withRenderingMode(.alwaysTemplate)
        
        let blockUser = UIAction(title: "Bloquear cliente",
                                    image: tintedImage,
                                    identifier: nil,
                                    discoverabilityTitle: nil,
                                    attributes: .destructive,
                                    handler: { _ in
        })
        
        let menu = UIMenu(title: "", options: .displayInline, children: [ordersHistory , addMissing, blockUser])
    
        moreButton.menu = menu
        moreButton.showsMenuAsPrimaryAction = true
    }
    
    func alert(title: String?, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: K.Texts.ok, style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        return
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.Segues.clientDetailsToOrdersHistory {
            let destinationVC = segue.destination as! OrdersHistoryViewController
            destinationVC.user = user
        }
    }
    
}
