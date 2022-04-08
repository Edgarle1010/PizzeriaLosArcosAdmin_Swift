//
//  OrderDetailsViewController.swift
//  PizzeriaLosArcosAdmin
//
//  Created by Edgar López Enríquez on 07/04/22.
//

import UIKit
import Firebase
import ProgressHUD

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
    @IBOutlet weak var dateRequest: UILabel!
    @IBOutlet weak var dateProcessed: UILabel!
    @IBOutlet weak var dateFinished: UILabel!
    @IBOutlet weak var dateDelivered: UILabel!
    
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
    
    
    func loadViews() {
        let backButtonImage = UIImage(named: K.Images.back)
        let backButtonTintedImage = backButtonImage?.withRenderingMode(.alwaysTemplate)
        backButton.setImage(backButtonTintedImage, for: .normal)
        backButton.tintColor = UIColor.init(named: K.BrandColors.primaryColor)
        
        let printButtonImage = UIImage(named: K.Images.more)
        let printButtonTintedImage = printButtonImage?.withRenderingMode(.alwaysTemplate)
        moreButton.setImage(printButtonTintedImage, for: .normal)
        moreButton.tintColor = UIColor.init(named: K.BrandColors.primaryColor)
        
        totalView.dropShadow()
        totalView.layer.cornerRadius = 12
        totalView.layer.masksToBounds = true;
        
        statusView.dropShadow()
        statusView.layer.cornerRadius = 12
        statusView.layer.masksToBounds = true;
        
        dateView.dropShadow()
        dateView.layer.cornerRadius = 12
        dateView.layer.masksToBounds = true;
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
                            self.totalLabel.text = "\(order.totalPrice)"
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
        alert.addAction(UIAlertAction(title: K.Texts.ok, style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        return
    }
    
}

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
