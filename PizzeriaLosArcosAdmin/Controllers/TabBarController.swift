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
