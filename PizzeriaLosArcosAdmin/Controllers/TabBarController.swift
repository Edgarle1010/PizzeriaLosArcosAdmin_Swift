//
//  TabBarController.swift
//  PizzeriaLosArcosAdmin
//
//  Created by Edgar López Enríquez on 29/03/22.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift

class TabBarController: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        
        self.navigationItem.title = "Recepción"

    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationItem.hidesBackButton = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationItem.hidesBackButton = false
    }
    
    @IBAction func logoutPressed(_ sender: UIButton) {
        let alert = UIAlertController(title: nil, message: "¿Estás seguro que deseas salir?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Sí, salir", style: .default, handler: { action in
            do { try Auth.auth().signOut() }
            catch { print("already logged out") }
            
            self.navigationController?.popToRootViewController(animated: true)
        }))
        alert.addAction(UIAlertAction(title: "Cancelar", style: UIAlertAction.Style.cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if let currentVC = viewController.restorationIdentifier {
            switch currentVC {
            case K.ViewControllers.inProcessViewController:
                self.navigationItem.title = "Recepción"
            case K.ViewControllers.splitViewController:
                self.navigationItem.title = "Clientes"
            case K.ViewControllers.menuSplitViewController:
                self.navigationItem.title = "Menú"
            default:
                break;
            }
        }
    }
}
