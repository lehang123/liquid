//
//  ChangePWViewController.swift
//  ITProject
//
//  Created by 陳信宏保佑🙏 on 2019/8/16.
//  Copyright © 2019 liquid. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class ChangePasswordViewController : UIViewController {
    
    private static let PASSWORD_INVALID = "The original password is invalid"
    private static let PASSWORD_LENGTH_NOT_ENOUGH = "Minimum length is 8"
    private static let CONFIRMED_INCORRECT_WRONG = "Mismatch password, please try again"
    private static let ACCOUNT_INCORRECT_MESSAGE = "Please try again"
    private static let CREATE_CORRECT = "Congratulation!"
    private static let PASSWORD_CHANGE_SUCCESS = "Password has been changed."

    @IBOutlet weak var originalPW: UITextField!
    @IBOutlet weak var newPW: UITextField!
    @IBOutlet weak var confirmedPassword: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func Confirm(_ sender: Any) {
        
        print (newPW!)
        print (confirmedPassword!)
        //make sure both new and old passwords are at least 8 characters.
        if (newPW.text!.count < 8) {
            Util.ShowAlert(title: ChangePasswordViewController.PASSWORD_LENGTH_NOT_ENOUGH,
                           message: ChangePasswordViewController.ACCOUNT_INCORRECT_MESSAGE,
                           action_title: Util.BUTTON_DISMISS,
                           on: self)
        }
        if (originalPW.text!.count<8){
            Util.ShowAlert(title: ChangePasswordViewController.PASSWORD_INVALID,
                           message: ChangePasswordViewController.ACCOUNT_INCORRECT_MESSAGE,
                           action_title: Util.BUTTON_DISMISS,
                           on: self)
        }

        if (newPW.text == confirmedPassword.text) {
    
            let user = Auth.auth().currentUser
            let credential: AuthCredential = EmailAuthProvider.credential(withEmail: (user?.email)!, password: originalPW.text!)
            
            // Prompt the user to re-provide their sign-in credentials
            user?.reauthenticate(with: credential, completion: {(authResult, error) in
                if error != nil {
                    // An error happened.
                    Util.ShowAlert(title: error!.localizedDescription, message: ChangePasswordViewController.ACCOUNT_INCORRECT_MESSAGE, action_title: Util.BUTTON_DISMISS, on: self)
                }else{
                    // User re-authenticated.
                    self.updatePassword(newPW : self.newPW.text!)
                }
            })
            
        } else {
            Util.ShowAlert(title: ChangePasswordViewController.CONFIRMED_INCORRECT_WRONG,
                           message: ChangePasswordViewController.ACCOUNT_INCORRECT_MESSAGE,
                           action_title: Util.BUTTON_DISMISS,
                           on: self)
        }

    }

    func updatePassword(newPW : String) {
        Auth.auth().currentUser?.updatePassword(to: newPW) { (error) in

            if (error == nil) {
                
                Util.ShowAlert(title: ChangePasswordViewController.CREATE_CORRECT, message: ChangePasswordViewController.PASSWORD_CHANGE_SUCCESS, action_title: ChangePasswordViewController.CREATE_CORRECT, on: self ){
                    
                    // pop back to the family view
//                    self.navigationController?.popViewController(animated: true)
                    self.navigationController?.popToRootViewController(animated: true)
                }
                
            }else {
                Util.ShowAlert(title: error!.localizedDescription,
                               message: ChangePasswordViewController.ACCOUNT_INCORRECT_MESSAGE, action_title:  Util.BUTTON_DISMISS,
                                   on: self )
            }
            
        }
    }

}
