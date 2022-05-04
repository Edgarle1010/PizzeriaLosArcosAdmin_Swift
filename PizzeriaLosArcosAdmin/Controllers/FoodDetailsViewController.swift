//
//  FoodDetailsViewController.swift
//  PizzeriaLosArcosAdmin
//
//  Created by Edgar López Enríquez on 28/04/22.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift
import ProgressHUD

class FoodDetailsViewController: UIViewController {
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var bPriceTextField: UITextField!
    @IBOutlet weak var mPriceTextField: UITextField!
    @IBOutlet weak var sPriceTextField: UITextField!
    @IBOutlet weak var listPositionTextField: UITextField!
    @IBOutlet weak var extraIngredientButton: UIButton!
    @IBOutlet weak var saveButton: ButtonWithShadow!
    @IBOutlet weak var cancelButton: ButtonWithShadow!
    
    var listener: ListenerRegistration?
    
    var foodType: String?
    var food: Food? {
        didSet {
            if let listener = listener {
                listener.remove()
            }
            loadFoodData(food!)
        }
    }
    var extraIngredientsList: [ExtraIngredient] = []
    
    let db = Firestore.firestore()

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
        guard let food = food else {
            return
        }

        loadFoodData(food)
    }
    
    func loadFoodData(_ food: Food) {
        ProgressHUD.show()
        listener = db.collection(K.Firebase.foodCollection).whereField(K.Firebase.id, isEqualTo: food.id)
            .addSnapshotListener { querySnapshot, error in
                ProgressHUD.dismiss()
                if let error = error {
                    self.alert(title: K.Texts.problemOcurred, message: error.localizedDescription)
                } else {
                    if let documents = querySnapshot?.documents {
                        for doc in documents {
                            let result = Result {
                                try doc.data(as: Food.self)
                            }
                            switch result {
                            case .success(let food):
                                DispatchQueue.main.async {
                                    self.blockInterface(food)
                                }
                            case .failure(let error):
                                print("Error decoding food: \(error)")
                            }
                        }
                    }
                }
            }
    }
    
    private func refreshUI(_ food: Food) {
        loadViewIfNeeded()
        titleLabel.text = food.title
        descriptionTextView.text = food.description
        bPriceTextField.text = "$\(food.bPrice)"
        mPriceTextField.text = "$\(food.mPrice ?? 0)"
        sPriceTextField.text = "$\(food.sPrice ?? 0)"
        listPositionTextField.text = "\(food.listPosition ?? 0)"
        
        guard let foodType = foodType else {
            return
        }
        getExtraIngredients(foodType)
        
        setMenuMore(food)
    }
    
    func getExtraIngredients(_ foodType: String) {
        extraIngredientsList.removeAll()
        ProgressHUD.show()
        db.collection(K.Firebase.extraIngredientsCollection).order(by: K.Firebase.listPosition)
            .getDocuments { (querySnapshot, error) in
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
                                    if extraIngredient.food.contains(foodType) {
                                        self.extraIngredientsList.append(extraIngredient)
                                    }
                                case .failure(let error):
                                    print("Error decoding food: \(error)")
                                }
                        }
                        
                        DispatchQueue.main.async {
                            self.extraIngredientButton.setTitle("\(self.extraIngredientsList.count)", for: .normal)
                        }
                    }
                }
            }
    }
    
    func setMenuMore(_ food: Food) {
        let editFood = UIAction(title: "Editar",
                                image: UIImage(named: K.Images.edit),
                                identifier: nil
        ) { _ in
            self.enableInterface(food)
        }
        
        let menu = UIMenu(title: "", options: .displayInline, children: [editFood])
    
        moreButton.menu = menu
        moreButton.showsMenuAsPrimaryAction = true
    }
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        guard let food = food else {
            return
        }
        saveData(food)
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        guard let food = food else {
            return
        }

        blockInterface(food)
    }
    
    func saveData(_ food: Food) {
        ProgressHUD.show()
        db.collection(K.Firebase.foodCollection)
            .whereField(K.Firebase.id, isEqualTo: food.id)
            .getDocuments { querySnapshot, error in
                ProgressHUD.dismiss()
                if let error = error {
                    self.alert(title: K.Texts.problemOcurred, message: error.localizedDescription)
                } else {
                    if let documents = querySnapshot?.documents {
                        if documents.count != 0 {
                            for doc in documents {
                                ProgressHUD.show()
                                self.db.collection(K.Firebase.foodCollection).document(doc.documentID).updateData([
                                    K.Firebase.description: self.descriptionTextView.text ?? food.description!,
                                    K.Firebase.listPosition: Int(self.listPositionTextField.text!) ?? food.listPosition!,
                                    K.Firebase.bPrice: Int(self.bPriceTextField.text!) ?? food.bPrice,
                                    K.Firebase.mPrice: Int(self.mPriceTextField.text!) ?? food.mPrice ?? 0,
                                    K.Firebase.sPrice: Int(self.sPriceTextField.text!) ?? food.sPrice ?? 0
                                ]) { err in
                                    ProgressHUD.dismiss()
                                    if let err = err {
                                        self.alert(title: K.Texts.problemOcurred, message: err.localizedDescription)
                                    } else {
                                        ProgressHUD.show()
                                        self.db.collection(K.Firebase.foodCollection).document(doc.documentID)
                                            .getDocument { querySnapshot, error in
                                                ProgressHUD.dismiss()
                                                if let error = error {
                                                    self.alert(title: K.Texts.problemOcurred, message: error.localizedDescription)
                                                } else {
                                                    let result = Result {
                                                        try querySnapshot?.data(as: Food.self)
                                                    }
                                                    switch result {
                                                    case .success(let food):
                                                        DispatchQueue.main.async {
                                                            guard let food = food else {
                                                                return
                                                            }
                                                            self.food = food
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
    
    func enableInterface(_ food: Food) {
        self.saveButton.isHidden = false
        self.saveButton.alpha = 1
        self.cancelButton.isHidden = false
        self.cancelButton.alpha = 1
        
        self.descriptionTextView.isEditable = true
        self.descriptionTextView.alpha = 1
        
        self.bPriceTextField.isEnabled = true
        self.bPriceTextField.text = "\(food.bPrice)"
        self.bPriceTextField.alpha = 1
        
        self.mPriceTextField.isEnabled = true
        self.mPriceTextField.text = "\(food.mPrice ?? 0)"
        self.mPriceTextField.alpha = 1
        
        self.sPriceTextField.isEnabled = true
        self.sPriceTextField.text = "\(food.sPrice ?? 0)"
        self.sPriceTextField.alpha = 1
        
        self.listPositionTextField.isEnabled = true
        self.listPositionTextField.alpha = 1
        
        self.extraIngredientButton.isEnabled = true
        self.extraIngredientButton.alpha = 1
    }
    
    func blockInterface(_ food: Food) {
        UIView.animate(withDuration: 0.3, animations: {
            self.saveButton.alpha = 0
            self.cancelButton.alpha = 0
        }) { (finished) in
            self.saveButton.isHidden = true
            self.cancelButton.isHidden = true
            
            self.descriptionTextView.isEditable = false
            self.descriptionTextView.alpha = 0.5
            
            self.bPriceTextField.isEnabled = false
            self.bPriceTextField.alpha = 0.5
            
            self.mPriceTextField.isEnabled = false
            self.mPriceTextField.alpha = 0.5
            
            self.sPriceTextField.isEnabled = false
            self.sPriceTextField.alpha = 0.5
            
            self.listPositionTextField.isEnabled = false
            self.listPositionTextField.alpha = 0.5
            
            self.extraIngredientButton.isEnabled = false
            self.extraIngredientButton.alpha = 0.5
            
            
            self.refreshUI(food)
        }
    }
    
    @IBAction func extraIngredientPressed(_ sender: UIButton) {
        performSegue(withIdentifier: K.Segues.foodDetailsToExtraIngredients, sender: self)
    }
    
    func alert(title: String?, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: K.Texts.ok, style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        return
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.Segues.foodDetailsToExtraIngredients {
            let destinationVC = segue.destination as! ExtraIngredientsListViewController
            destinationVC.foodType = foodType
        }
    }

}
