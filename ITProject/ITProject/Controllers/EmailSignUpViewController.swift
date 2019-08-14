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
//                self.AddUser(userUID: authResult!.user.uid);
                //AddNewFamily(userUID : userUID);
              //  self.AddUserToExistingFamily();
                self.UpdateUser();
                
                
            }
        }
    }
    public func AddUser(userUID: String){
        let userUID = DBController.getInstance().addDocumentToCollection(inputData: ["username" : self.realusername.text!, "userUID": userUID], collectionName: "users");
        
        
        
    }
    
    
    public func AddNewFamily(userUID:  DocumentReference){
        // creates  new family
        let familyUID = DBController.getInstance().addDocumentToCollection(inputData: ["name" : self.familyCreate.text!], collectionName: "families");
        // adds to new family_member
        // TODO: parametrise "position" field
        DBController.getInstance().addDocumentToCollection(inputData: ["family" : familyUID, "user" : userUID, "position" : "child" ], collectionName: "family_members" );
        
        
    }
    
    public func UpdateUser(){
        DBController.getInstance().updateSpecificField(newValue: "hi", fieldName: "name", documentName: "chenghongloveme", collectionName: "users");
        
    }
    public func DeleteUser(){
        DBController.getInstance().deleteWholeDocumentfromCollection(documentName: realusername.text!, collectionName: "users");
        
    }
    
    
    public func AddUserToExistingFamily(){
        //get familyUID's
        //let querySnapshot : QuerySnapshot =
         DBController.getInstance().getDatafromDocument(fieldName: "name", documentName: self.familyExist.text!, collectionName: "families");
        
        //querySnapshot.documents[0].documentID
//         DBController.getInstance().addDocumentToCollection(inputData: ["name" : self.familyCreate.text!], collectionName: "families");
        // adds to existing family
        

    }
        
}

