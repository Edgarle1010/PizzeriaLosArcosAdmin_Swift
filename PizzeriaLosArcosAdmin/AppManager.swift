//
//  AppManager.swift
//  PizzeriaLosArcos
//
//  Created by Edgar López Enríquez on 01/01/22.
//

import UIKit
import Firebase
import ProgressHUD
 
class AppManager {
    let window = (UIApplication.shared.connectedScenes.first!.delegate as! SceneDelegate).window
    static let shared = AppManager()
    private let storyboard = UIStoryboard(name: "Main", bundle: nil)
    var appContainer: LoginViewController!
    private init() { }
    
    func showApp() {
        var viewController: UIViewController
        if Auth.auth().currentUser != nil {
            ProgressHUD.show()
            viewController = storyboard.instantiateViewController(withIdentifier: "TabBarController")
            appContainer.navigationController?.pushViewController(viewController, animated: true)
            ProgressHUD.dismiss()
        } 
    }
}
