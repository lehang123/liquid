//
//  ViewController.swift
//  ITProject/Users/zhuchenghong/Desktop/liquid/ITProject/ITProject/Controllers/ChangePWViewController.swift
//
//  Created by Gong Lehan on 6/8/19.
//  Copyright © 2019 liquid. All rights reserved.
//

import Foundation
import UIKit
import Firebase

/// <#Description#>
/// This view is mainly for user to log in
class LoginViewController: UIViewController {
    
    // Constants and properties go here
    private static let ACCOUNT_INCORRECT_TITLE = "Email/Password Incorrect"
    private static let ACCOUNT_INCORRECT_MESSAGE = "Try Again"

    @IBOutlet weak var ID: UITextField!
    @IBOutlet weak var password: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        let tapGestureBackground = UITapGestureRecognizer(target: self, action: #selector(self.backgroundTapped(_:)))
        self.view.addGestureRecognizer(tapGestureBackground)
    }
    
    /// <#Description#>
    /// Detect the user tapped on the background
    ///
    /// - Parameter sender: <#sender description#>
    @objc func backgroundTapped(_ sender: UITapGestureRecognizer)
    {
        self.ID.endEditing(true)
        self.password.endEditing(true)
    }
    
    /// <#Description#>
    /// Show the keyboard to the user
    ///
    /// - Parameter notification: notification
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {

            if password.isEditing{
                
                if self.view.frame.origin.y == 0 {
                    UIView.animate(withDuration: 0.25, animations: {
                        self.view.frame.origin.y -= keyboardSize.height
                    })
                }
            }
        }
    }
    
    /// <#Description#>
    /// Hide the keyboard
    ///
    /// - Parameter notification: notification
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            UIView.animate(withDuration: 0.25, animations: {
                 self.view.frame.origin.y = 0
            })
        }
    }

    /// <#Description#>
    /// When user touched the buttom to log in
    ///
    /// - Parameter sender: sender
    @IBAction func LoginButtonOnTouch(_ sender: Any) {
        let account: String = ID.text!
        let pw: String = password.text!
        Util.ShowActivityIndicator(withStatus: "login...")
        Auth.auth().signIn(withEmail: account, password: pw) { [weak self] user, error in 
            if error != nil {
                Util.DismissActivityIndicator()
                let alertController = UIAlertController(title: LoginViewController.ACCOUNT_INCORRECT_TITLE, message:
                    LoginViewController.ACCOUNT_INCORRECT_MESSAGE, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: Util.BUTTON_DISMISS, style: .default))
                self?.present(alertController, animated: true, completion: nil)
            } else {
                Util.DismissActivityIndicator()

                self?.dismiss(animated: true, completion: nil)
                
            }
        }
    }

}

