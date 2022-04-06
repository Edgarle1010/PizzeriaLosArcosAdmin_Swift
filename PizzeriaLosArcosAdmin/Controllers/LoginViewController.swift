//
//  ViewController.swift
//  PizzeriaLosArcosAdmin
//
//  Created by Edgar López Enríquez on 28/03/22.
//

import UIKit
import Firebase
import ProgressHUD

class LoginViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var userTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let standardAppearance = UINavigationBarAppearance()

        standardAppearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(named: K.BrandColors.primaryColor)!]

        standardAppearance.configureWithOpaqueBackground()
        standardAppearance.backgroundColor = UIColor(named: K.BrandColors.secundaryColor)

        self.navigationController?.navigationBar.standardAppearance = standardAppearance
        self.navigationController?.navigationBar.scrollEdgeAppearance = standardAppearance
        
        AppManager.shared.appContainer = self
        AppManager.shared.showApp()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = false
    }
    
    func loginWithPhoneNumberPasswordUser(_ phoneNumber: String, _ password: String) {
        ProgressHUD.show()
        db.collection(K.Firebase.userCollection).whereField(K.Firebase.phoneNumberField, isEqualTo: phoneNumber)
            .getDocuments { (querySnapshot, error) in
                ProgressHUD.dismiss()
                if let error = error {
                    self.alert(title: "¡Ha ocurrido un problema!", message: error.localizedDescription)
                } else {
                    if let documents = querySnapshot?.documents {
                        if documents.count != 0 {
                            for doc in documents {
                                let data = doc.data()
                                if let email = data[K.Firebase.emailField] as? String {
                                    
                                    DispatchQueue.main.async {
                                        self.loginEmailPasswordUser(email, password)
                                    }
                                }
                            }
                        } else {
                            self.alert(title: "¡Ha ocurrido un problema!", message: "No hay ningún usuario registrado con este número")
                        }
                    }
                }
        }
    }
    
    func loginEmailPasswordUser(_ email: String, _ password: String) {
        ProgressHUD.show()
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            ProgressHUD.dismiss()
            if let error = error {
                self.alert(title: "¡Ha ocurrido un problema!", message: error.localizedDescription)
            } else {
                self.performSegue(withIdentifier: K.Segues.loginToMenu, sender: self)
            }
        }
    }
    
    func alert(title: String?, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        return
    }

    @IBAction func loginPressed(_ sender: UIButton) {
        if let user = userTextField.text, let password = passwordTextField.text {
            loginWithPhoneNumberPasswordUser(user, password)
        }
    }
    
}

