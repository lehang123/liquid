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
    

    @IBOutlet weak var profilePicture: EnhancedCircleImageView!
    //@IBOutlet weak var name: UILabel!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var relationship: UITextField!
<<<<<<< HEAD
    @IBOutlet weak var phoneNumber: UITextField!
    @IBOutlet weak var gender: UITextField!
=======
    @IBOutlet weak var genderField: UITextField!
    @IBOutlet weak var phoneField: UITextField!
    
    var userInformation: SideMenuTableViewController.UserInfo!
>>>>>>> 51e5171319bc4712b9a3b6b498edd0d412c8c831
    
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
        })

        
        self.name.text = userInformation.username
        self.relationship.text = userInformation.familyRelation
        self.phoneField.text = userInformation.phone
        self.genderField.text = userInformation.gender?.rawValue
    }

<<<<<<< HEAD
    // To do change the username in database also in cache
    // To do change the username in database also in cache
    // To do change the username in database also in cache
    // To do change the username in database also in cache
    @objc func DoneButtonTapped() {
=======
    @objc private func DoneButtonTapped() {
>>>>>>> 51e5171319bc4712b9a3b6b498edd0d412c8c831
        
        print("Button Tapped")
        let user = Auth.auth().currentUser
        
        //get current name:
//        var userData : [String:Any] = CacheHandler.getInstance().getCache(forKey: CacheHandler.USER_DATA) as! [String : Any];
//        let userName : String = userData[RegisterDBController.USER_DOCUMENT_FIELD_NAME] as! String;
        
<<<<<<< HEAD
    
        if (name.text != userName ) {
            
            Util.ShowAlert(title: ProfileViewController.CHANGED_INFO, message: ProfileViewController.CHANGED_MESSAGE, action_title: Util.BUTTON_DISMISS, on: self)
            
           // CacheHandler.getInstance().setCache(obj: name.text as AnyObject, forKey: "name" as AnyObject)
            //set new name:
            
            //user?.uid
            DBController.getInstance().updateSpecificField(newValue: name.text!, fieldName: RegisterDBController.USER_DOCUMENT_FIELD_NAME, documentUID: user!.uid, collectionName: RegisterDBController.USER_COLLECTION_NAME)
            CacheHandler.getInstance().cacheUser();
        }
=======
        
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
//
//        }
>>>>>>> 51e5171319bc4712b9a3b6b498edd0d412c8c831
        
        
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

