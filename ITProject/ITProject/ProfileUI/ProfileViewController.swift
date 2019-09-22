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

/// <#Description#>
/// This view controller is mainly to show all the information that user has signed
class ProfileViewController: UIViewController {
    
    // Constants and properties go here
    private static let CHANGED_INFO = "Succesfully"
    private static let CHANGED_MESSAGE = "The information has changed"
    private var keyboardSize:CGRect!
    private var imagePicker = UIImagePickerController()
    var currentRelationship:String?
    var currentGender:String?
    var userInformation: UserInfo!
    var didChangeUserInfo:Bool = false
    var didChangeUserProfile:Bool = false
    
    @IBOutlet weak var profilePicture: EnhancedCircleImageView!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var relationship: UITextField!
    @IBOutlet weak var genderField: UITextField!
    @IBOutlet weak var phoneField: UITextField!
    
    
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
        
        self.didChangeUserInfo = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        // but to stop editing when the user taps anywhere on the view, add this gesture recogniser
        let tapGestureBackground = UITapGestureRecognizer(target: self, action: #selector(self.backgroundTapped(_:)))
        self.view.addGestureRecognizer(tapGestureBackground)
    }
    
    /// <#Description#>
    /// hide the keyboard
    ///
    /// - Parameter sender: tap the background
    @objc func backgroundTapped(_ sender: UITapGestureRecognizer)
    {
        self.name.endEditing(true)
        self.relationship.endEditing(true)
        self.phoneField.endEditing(true)
        self.genderField.endEditing(true)
    }
    
    /// <#Description#>
    /// Show the keyboard
    ///
    /// - Parameter notification: notification description
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
    
    /// <#Description#>
    /// Touch the botton to lead to update photos
    ///
    /// - Parameter sender: <#sender description#>
    @IBAction func updateProfileImage(_ sender: Any) {
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        
        self.present(imagePicker, animated: true, completion:  nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        
        if self.isMovingFromParent && didChangeUserInfo {
            userInformation.userInfoDelegate.didUpdateUserInfo()
            print("view is disappearing from it's parent")
        }
        
    }
    
    
    /// <#Description#>
    /// When the button tapped, save all the changes that made by the user
    @objc func DoneButtonTapped() {
        let user = Auth.auth().currentUser
        
        if let u = user {
            if u.displayName != self.name.text{
                didChangeUserInfo = true
                Util.ChangeUserDisplayName(user: u, username: self.name.text!)
            }
        }

        //update DB according to what has changed:
        if (self.currentRelationship != self.relationship.text){
            didChangeUserInfo = true
            DBController.getInstance().updateSpecificField(newValue: self.relationship.text!, fieldName: RegisterDBController.USER_DOCUMENT_FIELD_POSITION, documentUID: user!.uid, collectionName: RegisterDBController.USER_COLLECTION_NAME);
            self.currentRelationship = self.relationship.text
        }
        if (self.currentGender != self.genderField.text){
            didChangeUserInfo = true
            DBController.getInstance().updateSpecificField(newValue: self.genderField.text!, fieldName: RegisterDBController.USER_DOCUMENT_FIELD_GENDER, documentUID: user!.uid, collectionName: RegisterDBController.USER_COLLECTION_NAME);
            self.currentGender = self.genderField.text
        }
        
        if didChangeUserProfile {
            didChangeUserProfile = false
            didChangeUserInfo = true
            if let imageData = self.profilePicture.image?.jpegData(compressionQuality: 1.0),
                let imageString = Util.GenerateUDID(){
                Util.ShowActivityIndicator(withStatus: "uploading Profile...")
                Util.UploadFileToServer(data: imageData, metadata: nil, fileName: imageString, fextension: Util.EXTENSION_JPEG, completion: {url in
                 
                    if url != nil{
                        // change photo url in auth service
                        Util.ChangeUserPhotoURL(imagePath:imageString , ext: Util.EXTENSION_JPEG)
                    }
                    Util.DismissActivityIndicator()
                }, errorHandler: {e in
                    print("you get error from Thumbnail choose")
                    Util.ShowAlert(title: "Error", message: e!.localizedDescription, action_title: Util.BUTTON_DISMISS, on: self)
                })
            }
        }

    }
    
    @IBAction private func close() {
        self.dismiss(animated: true, completion: nil)
    }
}

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    /// <#Description#>
    /// Pick the specific image
    ///
    /// - Parameters:
    ///   - picker: picker description
    ///   - info: info description
    internal func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // todo : push add/edit photo view
        didChangeUserProfile = true
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            self.profilePicture.image =
                editedImage.withRenderingMode(.alwaysOriginal)
        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.profilePicture.image = originalImage.withRenderingMode(.alwaysOriginal)
        }
        
        dismiss(animated: true, completion: nil)
    }

    /// <#Description#>
    /// delegate function from the UIImagePickerControllerDelegate
    /// called when canceled button pressed, get out of photo library
    ///
    /// - Parameter picker: picker
    internal func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        print ("imagePickerController: Did canceled pressed !!")
        picker.dismiss(animated: true, completion: nil)
    }
    
    
}


