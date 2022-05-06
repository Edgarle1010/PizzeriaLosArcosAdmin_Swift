//
//  ExtraIngredientDetailsViewController.swift
//  PizzeriaLosArcosAdmin
//
//  Created by Edgar López Enríquez on 03/05/22.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift
import ProgressHUD

class ExtraIngredientDetailsViewController: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var bPriceTextField: UITextField!
    @IBOutlet weak var mPriceTextField: UITextField!
    @IBOutlet weak var sPriceTextField: UITextField!
    @IBOutlet weak var listPositionTextField: UITextField!
    @IBOutlet weak var saveButton: ButtonWithShadow!
    @IBOutlet weak var cancelButton: ButtonWithShadow!
    
    var listener: ListenerRegistration?
    
    let db = Firestore.firestore()
    
    var extraIngredient: ExtraIngredient? {
        didSet {
            loadExtraIngredientData(extraIngredient!)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let moreButtonImage = UIImage(named: K.Images.more)
        let moreButtonTintedImage = moreButtonImage?.withRenderingMode(.alwaysTemplate)
        moreButton.setImage(moreButtonTintedImage, for: .normal)
        moreButton.tintColor = UIColor.init(named: K.BrandColors.primaryColor)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        listener?.remove()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let extraIngredient = extraIngredient else {
            return
        }

        loadExtraIngredientData(extraIngredient)
    }
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        guard let extraIngredient = extraIngredient else {
            return
        }
        
        saveData(extraIngredient)
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        guard let extraIngredient = extraIngredient else {
            return
        }

        blockInterface(extraIngredient)
        
        dismiss(animated: true)
    }
    
    func loadExtraIngredientData(_ extraIngredient: ExtraIngredient) {
        ProgressHUD.show()
        listener = db.collection(K.Firebase.extraIngredientsCollection).whereField(K.Firebase.id, isEqualTo: extraIngredient.id)
            .addSnapshotListener { querySnapshot, error in
                ProgressHUD.dismiss()
                if let error = error {
                    self.alert(title: K.Texts.problemOcurred, message: error.localizedDescription)
                } else {
                    if let documents = querySnapshot?.documents {
                        for doc in documents {
                            let result = Result {
                                try doc.data(as: ExtraIngredient.self)
                            }
                            switch result {
                            case .success(let extraIngredient):
                                DispatchQueue.main.async {
                                    self.blockInterface(extraIngredient)
                                }
                            case .failure(let error):
                                print("Error decoding food: \(error)")
                            }
                        }
                    }
                }
            }
    }
    
    private func refreshUI(_ extraIngredient: ExtraIngredient) {
        loadViewIfNeeded()
        titleLabel.text = extraIngredient.title
        bPriceTextField.text = "$\(extraIngredient.bPrice)"
        
        if let mPrice = extraIngredient.mPrice {
            mPriceTextField.text = "$\(mPrice)"
        } else {
            mPriceTextField.text = "N/A"
        }
        
        if let sPrice = extraIngredient.sPrice {
            sPriceTextField.text = "$\(sPrice)"
        } else {
            sPriceTextField.text = "N/A"
        }
        
        listPositionTextField.text = "\(extraIngredient.listPosition ?? 0)"
        
        setMenuMore(extraIngredient)
    }
    
    func blockInterface(_ extraIngredient: ExtraIngredient) {
        UIView.animate(withDuration: 0.3, animations: {
            self.saveButton.alpha = 0
            self.cancelButton.alpha = 0
        }) { (finished) in
            self.saveButton.isHidden = true
            self.cancelButton.isHidden = true
            
            self.bPriceTextField.isEnabled = false
            self.bPriceTextField.alpha = 0.5
            
            self.mPriceTextField.isEnabled = false
            self.mPriceTextField.alpha = 0.5
            
            self.sPriceTextField.isEnabled = false
            self.sPriceTextField.alpha = 0.5
            
            self.listPositionTextField.isEnabled = false
            self.listPositionTextField.alpha = 0.5
            
            self.refreshUI(extraIngredient)
        }
    }
    
    func enableInterface(_ extraIngredient: ExtraIngredient) {
        self.saveButton.isHidden = false
        self.saveButton.alpha = 1
        self.cancelButton.isHidden = false
        self.cancelButton.alpha = 1
        
        self.bPriceTextField.isEnabled = true
        self.bPriceTextField.text = "\(extraIngredient.bPrice)"
        self.bPriceTextField.alpha = 1
        
        if let mPrice = extraIngredient.mPrice {
            mPriceTextField.isEnabled = true
            mPriceTextField.text = "\(mPrice)"
            mPriceTextField.alpha = 1
        }
        
        if let sPrice = extraIngredient.sPrice {
            sPriceTextField.isEnabled = true
            sPriceTextField.text = "\(sPrice)"
            sPriceTextField.alpha = 1
        }
        
        self.listPositionTextField.isEnabled = true
        self.listPositionTextField.alpha = 1
    }
    
    func setMenuMore(_ extraIngredient: ExtraIngredient) {
        let editFood = UIAction(title: "Editar",
                                image: UIImage(named: K.Images.edit),
                                identifier: nil
        ) { _ in
            self.enableInterface(extraIngredient)
        }
        
        let menu = UIMenu(title: "", options: .displayInline, children: [editFood])
    
        moreButton.menu = menu
        moreButton.showsMenuAsPrimaryAction = true
    }
    
    func saveData(_ extraIngredient: ExtraIngredient) {
        ProgressHUD.show()
        db.collection(K.Firebase.extraIngredientsCollection)
            .whereField(K.Firebase.id, isEqualTo: extraIngredient.id)
            .getDocuments { querySnapshot, error in
                ProgressHUD.dismiss()
                if let error = error {
                    self.alert(title: K.Texts.problemOcurred, message: error.localizedDescription)
                } else {
                    if let documents = querySnapshot?.documents {
                        if documents.count != 0 {
                            for doc in documents {
                                ProgressHUD.show()
                                self.db.collection(K.Firebase.extraIngredientsCollection).document(doc.documentID).updateData([
                                    K.Firebase.listPosition: Int(self.listPositionTextField.text!) ?? extraIngredient.listPosition!,
                                    K.Firebase.bPrice: Int(self.bPriceTextField.text!) ?? extraIngredient.bPrice,
                                    K.Firebase.mPrice: Int(self.mPriceTextField.text!) as Any,
                                    K.Firebase.sPrice: Int(self.sPriceTextField.text!) as Any
                                ]) { err in
                                    ProgressHUD.dismiss()
                                    if let err = err {
                                        self.alert(title: K.Texts.problemOcurred, message: err.localizedDescription)
                                    } else {
                                        ProgressHUD.show()
                                        self.db.collection(K.Firebase.extraIngredientsCollection).document(doc.documentID)
                                            .getDocument { querySnapshot, error in
                                                ProgressHUD.dismiss()
                                                if let error = error {
                                                    self.alert(title: K.Texts.problemOcurred, message: error.localizedDescription)
                                                } else {
                                                    let result = Result {
                                                        try querySnapshot?.data(as: ExtraIngredient.self)
                                                    }
                                                    switch result {
                                                    case .success(let extraIngredient):
                                                        DispatchQueue.main.async {
                                                            guard let extraIngredient = extraIngredient else {
                                                                return
                                                            }
                                                            self.extraIngredient = extraIngredient
                                                        }
                                                    case .failure(let error):
                                                        print("Error decoding food: \(error)")
                                                    }
                                                }
                                            }
                                        
                                    }
                                }
                            }
                        } else {
                            self.alert(title: K.Texts.problemOcurred, message: "No hay ningún usuario registrado con este número")
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
    
}
