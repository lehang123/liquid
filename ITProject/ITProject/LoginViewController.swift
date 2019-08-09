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
                let alertController = UIAlertController(title: Util.ACCOUNT_INCORRECT_TITLE, message:
                    Util.ACCOUNT_INCORRECT_MESSAGE, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: .default))
                self?.present(alertController, animated: true, completion: nil)
            } else {
                let next = self?.storyboard?.instantiateViewController(withIdentifier: "MainViewController")
                self!.present(next!, animated: true, completion: nil)
                
            }
            
        }
        
        
    }
    
}

