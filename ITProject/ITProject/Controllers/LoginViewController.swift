//
//  ViewController.swift
//  ITProject
//
//  Created by Gong Lehan on 6/8/19.
//  Copyright © 2019 liquid. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class LoginViewController: UIViewController {
    
    private static let ACCOUNT_INCORRECT_TITLE = "Email/Password Incorrect"
    private static let ACCOUNT_INCORRECT_MESSAGE = "Try Again"

    @IBOutlet weak var ID: UITextField!
    @IBOutlet weak var password: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func LoginButtonOnTouch(_ sender: Any) {
        let account: String = ID.text!
        let pw: String = password.text!
        Auth.auth().signIn(withEmail: account, password: pw) { [weak self] user, error in 
            if error != nil {
                let alertController = UIAlertController(title: LoginViewController.ACCOUNT_INCORRECT_TITLE, message:
                    LoginViewController.ACCOUNT_INCORRECT_MESSAGE, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: Util.BUTTON_DISMISS, style: .default))
                self?.present(alertController, animated: true, completion: nil)
            } else {
//                let next = self?.storyboard?.instantiateViewController(withIdentifier: "MainViewController")
//                self?.navigationController?.pushViewController(next!, animated: true)
//                self?.present(next!, animated: true, completion: nil)
//                user?.user.uid
//                self?.testFunction();
                self?.dismiss(animated: true, completion: nil)
            }
        }
    }
    
//    public func testFunction(){
//        // Add a new document in collection "cities"
//        DBController.getInstance().getDB().collection("users").document("STH").setData([
//            "name": "Los Angeles",
//            "state": "CA",
//            "country": "USA"
//        ]) { err in
//            if let err = err {
//                print("test Error writing document: \(err)")
//            } else {
//                print(" test Document successfully written!")
//            }
//        }
//    }
}

