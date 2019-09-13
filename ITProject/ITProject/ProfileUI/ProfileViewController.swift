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
        getName()
        profilePicture.image=#imageLiteral(resourceName: "tempProfileImage")
        
        //self.tableView.delgate = self
    }

    @objc func DoneButtonTapped() {
        
        print("Button Tapped")
        let user = Auth.auth().currentUser
        
        //get current name:
        var userData : [String:Any] = CacheHandler.getInstance().getCache(forKey: CacheHandler.USER_DATA) as! [String : Any];
        var userName : String = userData[RegisterDBController.USER_DOCUMENT_FIELD_NAME] as! String;
        
        
        //
        if (name.text != userName ) {
            
            Util.ShowAlert(title: ProfileViewController.CHANGED_INFO, message: ProfileViewController.CHANGED_MESSAGE, action_title: Util.BUTTON_DISMISS, on: self)
            
           // CacheHandler.getInstance().setCache(obj: name.text as AnyObject, forKey: "name" as AnyObject)
            //set new name:
            
            //user?.uid
            DBController.getInstance().updateSpecificField(newValue: name.text!, fieldName: RegisterDBController.USER_DOCUMENT_FIELD_NAME, documentUID: user!.uid, collectionName: RegisterDBController.USER_COLLECTION_NAME)
            CacheHandler.getInstance().cacheUser();

        }
        

    }
    
    @IBAction private func close() {
        self.dismiss(animated: true, completion: nil)
    }
    
    // Get the name of the user.
    private func getName() {
        var userData : [String:Any] = CacheHandler.getInstance().getCache(forKey: CacheHandler.USER_DATA) as! [String : Any];
        var userName : String = userData[RegisterDBController.USER_DOCUMENT_FIELD_NAME] as! String;
        self.name.text =  userName
    }
    

}

