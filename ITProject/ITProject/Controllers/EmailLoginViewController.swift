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

class EmailLoginViewController : UIViewController {
//    var db: Firestore!
    
    @IBOutlet weak var emailAddress: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var confirmPW: UITextField!
    @IBOutlet weak var realusername: UITextField!
    @IBOutlet weak var familyExist: UITextField!
    @IBOutlet weak var familyCreate: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /* Lehan : don't init db here, init at the DBController */
//         db = Firestore.firestore()
    }
    
    @IBAction func CreateButtonOnTouch(_ sender: Any) {
        let email: String = emailAddress.text!
        let pw: String = password.text!
        checkEmptyFields()
        authentiate(email: email, pw: pw)
    }
    
    // Check is there any empty field when sign in the info
    func checkEmptyFields() {
        if (realusername.text!.isEmpty) {
            alert(first_p: Util.CREATE_USERNAME, second_p: Util.ACCOUNT_INCORRECT_MESSAGE, third_p: Util.BUTTON_DISMISS)
        }
        else if (familyExist.text!.isEmpty && familyCreate.text!.isEmpty) {
            alert(first_p: Util.CREATE_FAMILY, second_p: Util.ACCOUNT_INCORRECT_MESSAGE, third_p: Util.BUTTON_DISMISS)
        }
    }
    
    // Authentiate process is here
    // todo : put this out of UI thread
    func authentiate(email: String, pw: String) {
        Auth.auth().createUser(withEmail: email, password: pw) {
            authResult, error in
            
            if error!.localizedDescription.contains(Util.ACCOUNT_ALREADY_EXIST) {
                self.alert(first_p: Util.ACCOUNT_ALREADY_TITLE, second_p: Util.ACCOUNT_INCORRECT_MESSAGE, third_p: Util.BUTTON_DISMISS)
            }
            self.checkPassword(first_pw: self.password.text!, second_pw: self.confirmPW.text!)
            
            if error != nil {
                // Show error message to users to let them use correct email form
                self.alert(first_p: Util.CREATE_INCORRECT,second_p:Util.ACCOUNT_INCORRECT_MESSAGE,third_p: Util.BUTTON_DISMISS)
            } else {
                // Show the users that the account has been sucessfully created
                let alertController = UIAlertController(title: Util.CREATE_CORRECT, message:
                    Util.CREATE_CORRECT_MESSAGE, preferredStyle: .alert)
                
                // Back to the previous view controller for user to log in
                let changeView = UIAlertAction(title: "Back to login", style: .default){action in
                    self.navigationController?.popViewController(animated: true)
                }

                self.AddUser();
                
                // Add all actions to alert controller
//                alertController.addAction(UIAlertAction(title: Util.BUTTON_DISMISS, style: .default))
                alertController.addAction(changeView)
                self.present(alertController, animated: true, completion: nil)
                
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
    

    
    
    // Show alert message to users
    func alert(first_p: String, second_p: String, third_p: String) {
        let alertController = UIAlertController(title: first_p, message:second_p, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: third_p, style: .default))
        self.present(alertController, animated: true, completion: nil)
    }
    
    //Check the confirmed password is it match the first one
    func checkPassword(first_pw: String, second_pw: String) {
        if (first_pw != second_pw) {
            alert(first_p: Util.CONFIRMED_INCORRECT_WRONG, second_p: Util.ACCOUNT_INCORRECT_MESSAGE, third_p: Util.BUTTON_DISMISS)
        }
        
        if (first_pw.count < 8) {
            alert(first_p: Util.PASSWORD_LENGTH_NOT_ENOUTH, second_p: Util.ACCOUNT_INCORRECT_MESSAGE, third_p:      Util.BUTTON_DISMISS)
        }
    }

}
