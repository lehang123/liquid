//
//  MainViewController.swift
//  ITProject
//
//  Created by Gong Lehan on 7/8/19.
//  Copyright © 2019 liquid. All rights reserved.
//

import Foundation
import UIKit
import FirebaseStorage
import EnhancedCircleImageView

class FamilyProfileViewController: UIViewController {
    //Mark: Properties

    @IBOutlet weak var familyProfileImageView: EnhancedCircleImageView!
    
    @IBOutlet weak var updateProfileButton: UIButton!
    
    @IBOutlet weak var mottoTextView: UITextView!
    
    @IBOutlet weak var displayFamilyUID: UILabel!
    
    @IBOutlet weak var familyNameField: UITextField!
    
    var userFamilyInfo: UserFamilyInfo!
    
    var didChangeFamilyInfo:Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setUpView()
        
        self.familyNameField.text = userFamilyInfo.familyName
        self.displayFamilyUID.text = userFamilyInfo.familyUID
        self.mottoTextView.text = userFamilyInfo.familyMottoText
        
        // Set right bar button as Done to store any changes that user made
        let rightButtonItem = UIBarButtonItem.init(
            title: "Done",
            style: .done,
            target: self,
            action: #selector(DoneButtonTapped)
        )
        self.navigationItem.rightBarButtonItem = rightButtonItem

    }
    
    
    private func setUpView(){
        
        Util.GetImageData(imageUID: userFamilyInfo.familyProfileUID, UIDExtension: userFamilyInfo.familyProfileExtension, completion: {
            data in
            
            if let d = data{
                print("get image success : loading data to image")
                self.familyProfileImageView.image = UIImage(data: d)
            }else{
                print("get image fails : loading data to image")
                self.familyProfileImageView.image=#imageLiteral(resourceName: "item4")
            }
            self.familyProfileImageView.layer.shadowColor = UIColor.selfcGrey.cgColor
            self.familyProfileImageView.layer.shadowOpacity = 0.7
            self.familyProfileImageView.layer.shadowOffset = CGSize(width: 10, height: 10)
            self.familyProfileImageView.layer.shadowRadius = 1
            self.familyProfileImageView.clipsToBounds = false
        })
    
        self.mottoTextView.layer.borderWidth = 2.0
        self.mottoTextView.layer.cornerRadius = 8
        self.mottoTextView.layer.borderColor = UIColor.gray.cgColor
    
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    
        let tapGestureBackground = UITapGestureRecognizer(target: self, action: #selector(self.backgroundTapped(_:)))
        self.view.addGestureRecognizer(tapGestureBackground)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        if self.isMovingFromParent {
            // Your code...
            print("view is disappearing from it's parent")
        }
    }
    
    @objc func DoneButtonTapped() {
        // commit change to db
        print("FamilyProfileViewController : done button pressed, commit change to db,then dismiss")
        // if user commit change to db
        didChangeFamilyInfo = true
        userFamilyInfo.familyInfoDelegate.didUpdateFamilyInfo()
    }
    
    @objc func backgroundTapped(_ sender: UITapGestureRecognizer)
    {
        self.mottoTextView.endEditing(true)
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
    
}
