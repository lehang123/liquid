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
import FirebaseCore
import FirebaseFirestore

class EmailSignUpViewController : UIViewController {
//    var db: Firestore!
    
    private static let ACCOUNT_INCORRECT_TITLE = "Email/Password Incorrect"
    private static let ACCOUNT_INCORRECT_MESSAGE = "Try Again"
    private static let CONFIRMED_INCORRECT_WRONG = "Wrong Password"
    private static let PASSWORD_LENGTH_NOT_ENOUTH = "Minimum length is 8"
    private static let CREATE_INCORRECT = "Invalid Email Address"
    private static let CREATE_CORRECT = "Congratulation!"
    private static let CREATE_CORRECT_MESSAGE = "Account Success!"
    private static let CREATE_USERNAME = "Username cannot be empty"
    private static let CREATE_FAMILY = "Family fields cannot be empty (fill in either one)"
    private static let FAMILY_FIELD = "Family fields cannot be both filled"
    private static let ACCOUNT_ALREADY_EXIST = "The email address is already in use by another account."
    private static let ACCOUNT_ALREADY_TITLE = "The address is already exist"
    private static let BACK_TO_LOGIN = "Back to login"
    private static let WAITING_AUTHENTIATE = "Creating.."
    
    
    @IBOutlet weak var emailAddress: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var confirmPW: UITextField!
    @IBOutlet weak var realusername: UITextField!
    @IBOutlet weak var joinFamilyIDField: UITextField!    // joinFamilyIDField is UID of the document

    @IBOutlet weak var familyCreate: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /* todo : don't init db here, init at the DBController */
//         db = Firestore.firestore()
    }
    
    @IBAction func CreateButtonOnTouch(_ sender: Any) {
        let email: String = emailAddress.text!
        let pw: String = password.text!
        
         
        // only field filled up, then try authentiate
        if doesFieldFilledUp(){
            authentiate(email: email, pw: pw)
        }
        
    }
    
    // Check is there any empty field when sign in the info
    func doesFieldFilledUp()->Bool {
        if (realusername.text!.isEmpty) {
            Util.ShowAlert(title: EmailSignUpViewController.CREATE_USERNAME,
                  message: EmailSignUpViewController.ACCOUNT_INCORRECT_MESSAGE,
                  action_title: Util.BUTTON_DISMISS,
                  on: self)
            return false
        }
        else if (joinFamilyIDField.text!.isEmpty && familyCreate.text!.isEmpty) {
            Util.ShowAlert(title: EmailSignUpViewController.CREATE_FAMILY,
                  message: EmailSignUpViewController.ACCOUNT_INCORRECT_MESSAGE,
                  action_title: Util.BUTTON_DISMISS,
                  on: self)
            return false
        }
        else if ((!joinFamilyIDField.text!.isEmpty) && (!familyCreate.text!.isEmpty)){
            Util.ShowAlert(title: EmailSignUpViewController.FAMILY_FIELD,
                           message: EmailSignUpViewController.ACCOUNT_INCORRECT_MESSAGE,
                           action_title: Util.BUTTON_DISMISS,
                           on: self)
            return false
        }
        else if (password.text! != confirmPW.text!) {
            Util.ShowAlert(title: EmailSignUpViewController.CONFIRMED_INCORRECT_WRONG,
                  message: EmailSignUpViewController.ACCOUNT_INCORRECT_MESSAGE,
                  action_title: Util.BUTTON_DISMISS,
                  on: self)
            return false
        }
        else if (password.text!.count < 8) {
            Util.ShowAlert(title: EmailSignUpViewController.PASSWORD_LENGTH_NOT_ENOUTH,
                  message: EmailSignUpViewController.ACCOUNT_INCORRECT_MESSAGE,
                  action_title: Util.BUTTON_DISMISS,
                  on: self)
            return false
        }
        
        return true
    }
    
    // Authentiate process is here
    // note : Firebase authentiate is default set on other thread already
    func authentiate(email: String, pw: String) {
        Util.ShowActivityIndicator(withStatus: EmailSignUpViewController.WAITING_AUTHENTIATE)
        Auth.auth().createUser(withEmail: email, password: pw) {
            authResult, error in
            Util.DismissActivityIndicator()
            
            if error != nil {
                // fail
                Util.ShowAlert(title: error!.localizedDescription,
                               message: EmailSignUpViewController.ACCOUNT_INCORRECT_MESSAGE,
                               action_title: Util.BUTTON_DISMISS,
                               on: self)
            }else{
                // success
                // Show the users that the account has been sucessfully created
                
                Util.ShowAlert(title: EmailSignUpViewController.CREATE_CORRECT,
                               message:EmailSignUpViewController.CREATE_CORRECT_MESSAGE,
                               action_title: EmailSignUpViewController.BACK_TO_LOGIN,
                               on: self){self.navigationController?.popViewController(animated: true)}
                
                //TODO: add user information to database

                var familyUID:DocumentReference;
                if (!self.familyCreate.text!.isEmpty) {
                    
                    //create a family:
                    familyUID = RegisterDBController.getInstance().AddNewFamily(familyName: self.familyCreate.text!, userUID: authResult!.user.uid, username: self.realusername.text!);

                    //add a user: 
                    RegisterDBController.getInstance().AddUser(familyUID: familyUID.documentID, userUID: authResult!.user.uid, username: self.realusername.text!);

                    
                }else if(!self.joinFamilyIDField.text!.isEmpty) {
                    
                    familyUID = DBController.getInstance().getDB().document(RegisterDBController.FAMILY_COLLECTION_PATH.appendingPathComponent(self.joinFamilyIDField.text!));
                    //create a user:
                    RegisterDBController.getInstance().AddUser( familyUID : self.joinFamilyIDField.text! ,userUID: authResult!.user.uid, username: self.realusername.text!);
                    
                    //join a family:
                    RegisterDBController.getInstance().AddUserToExistingFamily(familyUID: self.joinFamilyIDField.text!, userUID: authResult!.user.uid)
                }
                

                
            }
        }
    }
    
 
}

