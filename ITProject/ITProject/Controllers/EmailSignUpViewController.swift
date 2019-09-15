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
    private static let PASSWORD_LENGTH_NOT_ENOUGH = "Minimum length is 8 characters"
    private static let CREATE_INCORRECT = "Invalid Email Address"
    private static let CREATE_CORRECT = "Congratulation!"
    private static let CREATE_CORRECT_MESSAGE = "Account Successfully created."
    private static let CREATE_USERNAME = "Username cannot be empty"
    private static let CREATE_FAMILY = "Family fields cannot be empty (fill in either one)."
    private static let FAMILY_FIELD = "Family fields cannot be both filled."
    private static let ACCOUNT_ALREADY_EXIST = "The email address is already in use by another account."
    private static let JOIN_FAMILY_NOT_EXIST = "Family doesn't exist."
    private static let ACCOUNT_ALREADY_TITLE = "The address  already exists."
    private static let BACK_TO_LOGIN = "Back to login."
    private static let WAITING_AUTHENTICATE = "Creating.."
    
    
    @IBOutlet weak var emailAddress: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var confirmPW: UITextField!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var joinFamilyIDField: UITextField!    // joinFamilyIDField is UID of the document

    @IBOutlet weak var newFamilyField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        let tapGestureBackground = UITapGestureRecognizer(target: self, action: #selector(self.backgroundTapped(_:)))
        self.view.addGestureRecognizer(tapGestureBackground)
    }
    
    @objc func backgroundTapped(_ sender: UITapGestureRecognizer)
    {
        self.emailAddress.endEditing(true)
        self.password.endEditing(true)
        self.confirmPW.endEditing(true)
        self.username.endEditing(true)
        self.joinFamilyIDField.endEditing(true)
        self.newFamilyField.endEditing(true)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            
            if newFamilyField.isEditing {
                
                if self.view.frame.origin.y == 0 {
                    UIView.animate(withDuration: 0.25, animations: {
                        self.view.frame.origin.y -= keyboardSize.height
                    })
                }
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            UIView.animate(withDuration: 0.25, animations: {
                self.view.frame.origin.y = 0
            })
        }
    }
    
    @IBAction func CreateButtonOnTouch(_ sender: Any) {
        let email: String = emailAddress.text!
        let pw: String = password.text!
        
         
        // only field filled up, then try authentiate
        if (doesFieldFilledUp()){
            print("if run:::")
            if (!self.joinFamilyIDField.text!.isEmpty){
                print("if2 run:::")
                Util.ShowActivityIndicator(withStatus: EmailSignUpViewController.WAITING_AUTHENTICATE)
                //check if family exists
                DBController.getInstance().getDocumentFromCollection(collectionName: RegisterDBController.FAMILY_COLLECTION_NAME, documentUID: self.joinFamilyIDField.text!){
                    (document, error) in
                    if let document = document, document.exists {
                        //let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                        self.authenticate(email: email, pw: pw)
                    } else {
                        Util.DismissActivityIndicator()
                        Util.ShowAlert(title: EmailSignUpViewController.JOIN_FAMILY_NOT_EXIST,
                                       message: EmailSignUpViewController.ACCOUNT_INCORRECT_MESSAGE,
                                       action_title: Util.BUTTON_DISMISS,
                                       on: self)
                    }
                }
            }
            else{
                self.authenticate(email: email, pw: pw)
            }
        }
    }
    
    // Check is there any empty field when sign in the info
    func doesFieldFilledUp()->Bool {
        if (username.text!.isEmpty) {
            Util.ShowAlert(title: EmailSignUpViewController.CREATE_USERNAME,
                  message: EmailSignUpViewController.ACCOUNT_INCORRECT_MESSAGE,
                  action_title: Util.BUTTON_DISMISS,
                  on: self)
            return false
        }
        else if (joinFamilyIDField.text!.isEmpty && newFamilyField.text!.isEmpty) {
            Util.ShowAlert(title: EmailSignUpViewController.CREATE_FAMILY,
                  message: EmailSignUpViewController.ACCOUNT_INCORRECT_MESSAGE,
                  action_title: Util.BUTTON_DISMISS,
                  on: self)
            return false
        }
        else if ((!joinFamilyIDField.text!.isEmpty) && (!newFamilyField.text!.isEmpty)){
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
            Util.ShowAlert(title: EmailSignUpViewController.PASSWORD_LENGTH_NOT_ENOUGH,
                  message: EmailSignUpViewController.ACCOUNT_INCORRECT_MESSAGE,
                  action_title: Util.BUTTON_DISMISS,
                  on: self)
            return false
        }
        
        return true
    }
    
    // Authentiate process is here
    // note : Firebase authentiate is default set on other thread already
    func authenticate(email: String, pw: String) {
        // check if join family exists
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
                if (!self.newFamilyField.text!.isEmpty) {

                    //create a family:
                    familyUID = RegisterDBController.getInstance().AddNewFamily(familyName: self.newFamilyField.text!, userUID: authResult!.user.uid);

                    //add a user: todo: can remove this from db(optional)
                    RegisterDBController.getInstance().AddUser(familyUID: familyUID.documentID, userUID: authResult!.user.uid, username: self.username.text!);
                    // add username in auth, add in database can be remove
                    Util.ChangeUserDisplayName(user: authResult!.user, username: self.username.text!)
                    
                }else if(!self.joinFamilyIDField.text!.isEmpty) {

                    //create a user:
                    RegisterDBController.getInstance().AddUser( familyUID : self.joinFamilyIDField.text! ,userUID: authResult!.user.uid, username: self.username.text!);
                    
                    //join a family:
                    RegisterDBController.getInstance().AddUserToExistingFamily(familyUID: self.joinFamilyIDField.text!, userUID: authResult!.user.uid);
                }              
            }
        }
    }
}

