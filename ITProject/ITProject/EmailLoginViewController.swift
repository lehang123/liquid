//
//  EmailLoginViewController.swift
//  ITProject
//
//  Created by 陳信宏保佑🙏 on 2019/8/7.
//  Copyright © 2019 liquid. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class EmailLoginViewController : UIViewController {
    
    @IBOutlet weak var emailAddress: UITextField!
    @IBOutlet weak var password: UITextField!

    @IBOutlet weak var username: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func CreateButtonOnTouch(_ sender: Any) {
                let email: String = emailAddress.text!
                let pw: String = password.text!
                authentiate(email: email, pw: pw)
    }
    
    // Authentiate process is here
    func authentiate(email: String, pw: String) {
        Auth.auth().createUser(withEmail: email, password: pw) {
            authResult, error in
            
            if error != nil {
                // Show error message to users to let them use correct email form
                self.alert(first_p: Util.CREATE_INCORRECT,second_p:Util.ACCOUNT_INCORRECT_MESSAGE,third_p: Util.BUTTON_DISMISS)
            } else {
                // Show the users that the account has been sucessfully created
                let alertController = UIAlertController(title: Util.CREATE_CORRECT, message:
                    Util.CREATE_CORRECT_MESSAGE, preferredStyle: .alert)
                
                // Back to the previous view controller for user to log in
                let changeView = UIAlertAction(title: "BACK", style: .default){action in
                    let next = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController")
                    self.present(next!, animated:true, completion:nil)
                }
                
                // Add all actions to alert controller
                alertController.addAction(UIAlertAction(title: Util.BUTTON_DISMISS, style: .default))
                alertController.addAction(changeView)
                self.present(alertController, animated: true, completion: nil)
                
            }
        }
    }
    
    // Show alert message to users
    func alert(first_p: String, second_p: String, third_p: String) {
        let alertController = UIAlertController(title: first_p, message:second_p, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: third_p, style: .default))
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    
    
    



}
