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
                Auth.auth().createUser(withEmail: email, password: pw) {
                    authResult, error in
                    
                    if error != nil {
                        // Show error message to users to let them use correct email form
                        let alertController = UIAlertController(title: Util.CREATE_INCORRECT, message:
                            Util.ACCOUNT_INCORRECT_MESSAGE, preferredStyle: .alert)
                        alertController.addAction(UIAlertAction(title: Util.BUTTON_DISMISS, style: .default))
                        self.present(alertController, animated: true, completion: nil)
                    } else {

                        // Show the users that the account has been sucessfully created
                        let alertController = UIAlertController(title: Util.CREATE_CORRECT, message:
                            Util.CREATE_CORRECT_MESSAGE, preferredStyle: .alert)
                        
                        // Back to the previous view controller for user to log in
                        
                        let changeView = UIAlertAction(title: "BACK", style: .default){action in
                            // I know I need to put something in here.
                            let next = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController")
                            self.present(next!, animated:true, completion:nil)
                        }
                        //self.present(next!, animated: true, completion: nil)
                        alertController.addAction(UIAlertAction(title: Util.BUTTON_DISMISS, style: .default))
                        alertController.addAction(changeView)
                        
                        
                        self.present(alertController, animated: true, completion: nil)
                        
                        
                    }
                }
    }
    
    
    



}
