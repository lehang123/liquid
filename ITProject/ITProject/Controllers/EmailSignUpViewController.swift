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
    private static let CREATE_FAMILY = "Family fields cannot be empty"
    private static let ACCOUNT_ALREADY_EXIST = "The email address is already in use by another account."
    private static let ACCOUNT_ALREADY_TITLE = "The address is already exist"
    private static let BACK_TO_LOGIN = "Back to login"
    private static let WAITING_AUTHENTIATE = "Creating.."
    
    
    @IBOutlet weak var emailAddress: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var confirmPW: UITextField!
    @IBOutlet weak var realusername: UITextField!
    @IBOutlet weak var familyExist: UITextField!
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
        else if (familyExist.text!.isEmpty && familyCreate.text!.isEmpty) {
            Util.ShowAlert(title: EmailSignUpViewController.CREATE_FAMILY,
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
            if error != nil && error!.localizedDescription
                .contains(EmailSignUpViewController.ACCOUNT_ALREADY_EXIST) {
                Util.ShowAlert(title: EmailSignUpViewController.ACCOUNT_ALREADY_TITLE,
                           message: EmailSignUpViewController.ACCOUNT_INCORRECT_MESSAGE,
                           action_title: Util.BUTTON_DISMISS,
                           on: self)
            }
            
            if error != nil {
                // Show error message to users to let them use correct email form
                Util.ShowAlert(title: EmailSignUpViewController.CREATE_INCORRECT,
                           message:EmailSignUpViewController.ACCOUNT_INCORRECT_MESSAGE,
                           action_title: Util.BUTTON_DISMISS,
                           on: self)
            } else {
                // Show the users that the account has been sucessfully created
                
                Util.ShowAlert(title: EmailSignUpViewController.CREATE_CORRECT,
                           message:EmailSignUpViewController.CREATE_CORRECT_MESSAGE,
                           action_title: EmailSignUpViewController.BACK_TO_LOGIN,
                           on: self){self.navigationController?.popViewController(animated: true)}
                
                //TODO: add user information to database
                self.AddUser();
                
            }
        }
    }
    public func AddUser(){
//        var ref: DocumentReference? = nil
//        let userName: String = realusername.text!
//        ref = db.collection("users").addDocument(data: [
//            "username" : userName
//        ]) { err in
//            if let err = err {
//                print("Error adding document: \(err)")
//            } else {
//                print("Document added with ID: \(ref!.documentID)")
//            }
//        }
    }

    //    private func AddNewFamily(){
    //        var ref: DocumentReference? = nil
    //        ref = db.collection("families").addDocument(data: [
    //            "familyname" : newFamilyName
    //        ]) { err in
    //            if let err = err {
    //                print("Error adding document: \(err)")
    //            } else {
    //                print("Document added with ID: \(ref!.documentID)")
    //            }
    //        }
    //    }
    
    // Show alert message to users : move to Util as other class might uses it as well
//    func alert(title: String, message: String, action_title: String, aaction: (() -> Void)? = nil) {
//        /*present alert always on UI/main thread */
//        DispatchQueue.main.async {
//            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
//            alertController.addAction(UIAlertAction(title: action_title, style: .default){action in
//                aaction!()})
//
//            self.present(alertController, animated: true, completion: nil)
//        }
//    }

}
