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
    private var imagePicker = UIImagePickerController()
    private var albumThumbnailImage : UIImage? = UIImage(named: Util.DEFAULT_IMAGE)
    private var albumThumbnailString: String = Util.DEFAULT_IMAGE

    @IBOutlet weak var profilePicture: EnhancedCircleImageView!
    //@IBOutlet weak var name: UILabel!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var relationship: UITextField!

    @IBOutlet weak var genderField: UITextField!
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
    
    @IBAction func changeProfilePhoto(_ sender: Any) {
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        
        self.present(imagePicker, animated: true, completion:  nil)
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

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    internal func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // todo : push add/edit photo view
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            self.albumThumbnailImage =
                editedImage.withRenderingMode(.alwaysOriginal)
        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.albumThumbnailImage = originalImage.withRenderingMode(.alwaysOriginal)
        }
        
        let imageData = self.albumThumbnailImage?.jpegData(compressionQuality: 1.0)
        let imageString = Util.GenerateUDID()!
        
        // todo : also update this string to db
        Util.UploadFileToServer(data: imageData!, metadata: nil, fileName: imageString, fextension: Util.EXTENSION_JPEG, completion: {url in
            
            if url != nil{
                self.albumThumbnailString = imageString
                print("ALBUMNAILSTIRNG", self.albumThumbnailString)
                
                // TODO : change in database
                self.profilePicture.image = #imageLiteral(resourceName: "tempProfileImage")
                
            }
            
        }, errorHandler: {e in
            print("you get error from Thumbnail choose")
            Util.ShowAlert(title: "Error", message: e!.localizedDescription, action_title: Util.BUTTON_DISMISS, on: self)
        })
        
        
        dismiss(animated: true, completion: nil)
    }
    
    /* delegate function from the UIImagePickerControllerDelegate
     called when canceled button pressed, get out of photo library
     */
    internal func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        print ("imagePickerController: Did canceled pressed !!")
        picker.dismiss(animated: true, completion: nil)
    }
    
    
}


