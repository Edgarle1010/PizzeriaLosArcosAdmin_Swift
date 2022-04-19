//
//  PushNotificationSender.swift
//  PizzeriaLosArcosAdmin
//
//  Created by Edgar López Enríquez on 05/04/22.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift
import ProgressHUD

class PushNotificationSender {
    func sendPushNotification(to token: String, title: String, body: String, folio: String, imagenURL: String?, options: String?) {
        let urlString = "https://fcm.googleapis.com/fcm/send"
        let url = NSURL(string: urlString)!
        let paramString: [String : Any] = ["to" : token,
                                           "notification" : ["title" : title, "body" : body, "sound": "default"],
                                           "data" : ["user" : "test_id"]
        ]
        let request = NSMutableURLRequest(url: url as URL)
        let db = Firestore.firestore()
        
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject:paramString, options: [.prettyPrinted])
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("key=AAAAjjxgeT0:APA91bEwGNLxD1B82n67E7Zn3PYRzuoO9SHfBwNUS7nV6tLr4UStmJ0DL2MSkj8-EtJV3l9h3jV85zBsVAO3Y_L1NaJkahFu5eeNEs6kZnjVubGdf-38-2S9_6vgXJs75enpo342u5se", forHTTPHeaderField: "Authorization")
        let task =  URLSession.shared.dataTask(with: request as URLRequest)  { (data, response, error) in
            do {
                if let jsonData = data {
                    if let jsonDataDict  = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: AnyObject] {
                        NSLog("Received data:\n\(jsonDataDict))")
                        
                        let notification = Notification(folio: folio, imageURL: imagenURL, title: title, description: body, options: options, userToken: token, viewed: false)
                        
                        ProgressHUD.show()
                        do {
                            ProgressHUD.dismiss()
                            let _ = try db.collection(K.Firebase.notificationsCollection).document().setData(from: notification)
                        }
                        catch {
                            print(error)
                        }
                    }
                }
            } catch let err as NSError {
                print(err.debugDescription)
            }
        }
        task.resume()
    }
}
