//
//  ProfileViewController.swift
//  ITProject
//
//  Created by Erya Wen on 2019/8/11.
//  Copyright © 2019 liquid. All rights reserved.
//

import Firebase
import UIKit
import EnhancedCircleImageView

class ProfileViewController: UIViewController {
    
    private static let CHANGED_INFO = "Succesfully"
    private static let CHANGED_MESSAGE = "The information has changed"
    
    private var keyboardSize:CGRect!

    @IBOutlet weak var profilePicture: EnhancedCircleImageView!
    //@IBOutlet weak var name: UILabel!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var relationship: UITextField!
    var currentRelationship:String?
    @IBOutlet weak var genderField: UITextField!
    var currentGender:String?
    @IBOutlet weak var phoneField: UITextField!
    
    var userInformation: UserInfo!
    
    var didChangeUserInfo:Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set right bar button as Done to store any changes that user made
        let rightButtonItem = UIBarButtonItem.init(
            title: "Done",
            style: .done,
            target: self,
            action: #selector(DoneButtonTapped)
        )
        self.navigationItem.rightBarButtonItem = rightButtonItem

        // Do any additional setup after loading the view.

        Util.GetImageData(imageUID: userInformation.imageUID, UIDExtension: userInformation.imageExtension, completion: {
            data in
        
            if let d = data{
                print("get image success : loading data to image")
                self.profilePicture.image = UIImage(data: d)
            }else{
                print("get image fails : loading data to image")
                self.profilePicture.image=#imageLiteral(resourceName: "item4")
            }
            self.profilePicture.layer.shadowColor = UIColor.selfcGrey.cgColor
            self.profilePicture.layer.shadowOpacity = 0.7
            self.profilePicture.layer.shadowOffset = CGSize(width: 10, height: 10)
            self.profilePicture.layer.shadowRadius = 1
            self.profilePicture.clipsToBounds = false
        })
        
        self.name.text = userInformation.username
        self.relationship.text = userInformation.familyRelation
        self.phoneField.text = userInformation.phone
        self.genderField.text = userInformation.gender?.rawValue
        
        self.currentRelationship = userInformation.familyRelation
        self.currentGender = self.genderField.text
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        // but to stop editing when the user taps anywhere on the view, add this gesture recogniser
        let tapGestureBackground = UITapGestureRecognizer(target: self, action: #selector(self.backgroundTapped(_:)))
        self.view.addGestureRecognizer(tapGestureBackground)
    }
    
    @objc func backgroundTapped(_ sender: UITapGestureRecognizer)
    {
        self.name.endEditing(true)
        self.relationship.endEditing(true)
        self.phoneField.endEditing(true)
        self.genderField.endEditing(true)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            
            if self.view.frame.origin.y == 0 {
                UIView.animate(withDuration: 0.25, animations: {
                    self.view.frame.origin.y -= keyboardSize.height
                })
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
    
//    func textFieldDidEndEditing(_ textField: UITextField) {
//        print("textFieldDidEndEditing : hello")
//    }
//
//    func textFieldDidBeginEditing(_ textField: UITextField) {
//        print("textFieldDidBeginEditing : hello " + keyboardSize.height.description)
//    }

    // To do change the username in database also in cache
    // To do change the username in database also in cache
    // To do change the username in database also in cache
    // To do change the username in database also in cache
    @objc func DoneButtonTapped() {
        let user = Auth.auth().currentUser
        
        didChangeUserInfo = true
        userInformation.userInfoDelegate.didUpdateUserInfo()
        
        //update DB according to what has changed:
        if (self.currentRelationship != self.relationship.text){
            DBController.getInstance().updateSpecificField(newValue: self.relationship.text!, fieldName: RegisterDBController.USER_DOCUMENT_FIELD_POSITION, documentUID: user!.uid, collectionName: RegisterDBController.USER_COLLECTION_NAME);
            self.currentRelationship = self.relationship.text
        }
        if (self.currentGender != self.genderField.text){
            DBController.getInstance().updateSpecificField(newValue: self.genderField.text!, fieldName: RegisterDBController.USER_DOCUMENT_FIELD_GENDER, documentUID: user!.uid, collectionName: RegisterDBController.USER_COLLECTION_NAME);
            self.currentGender = self.genderField.text
        }
        //get current name:
//        var userData : [String:Any] = CacheHandler.getInstance().getCache(forKey: CacheHandler.USER_DATA) as! [String : Any];
//        let userName : String = userData[RegisterDBController.USER_DOCUMENT_FIELD_NAME] as! String;
//
//
//        if (name.text != userName ) {
//
//            Util.ShowAlert(title: ProfileViewController.CHANGED_INFO, message: ProfileViewController.CHANGED_MESSAGE, action_title: Util.BUTTON_DISMISS, on: self)
//
//           // CacheHandler.getInstance().setCache(obj: name.text as AnyObject, forKey: "name" as AnyObject)
//            //set new name:
//
//            //user?.uid
//            DBController.getInstance().updateSpecificField(newValue: name.text!, fieldName: RegisterDBController.USER_DOCUMENT_FIELD_NAME, documentUID: user!.uid, collectionName: RegisterDBController.USER_COLLECTION_NAME)
//            CacheHandler.getInstance().cacheUser();
//        }
        
        
        // !!!!
        // Here if these information not the same as before.
        // Change the info in database and cache
        // TO DO!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        //if (phoneNumber.text != (The thing store in databse)) {}
        
        //if (gender.text != (The thing store in datasase)) {}
        

    }
    
    @IBAction private func close() {
        self.dismiss(animated: true, completion: nil)
    }
}

