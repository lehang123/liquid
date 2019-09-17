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

class FamilyProfileViewController: UIViewController, UITextViewDelegate {
    //Mark: Properties
    
    private static let TEXT_VIEW_WORD_LIMIT = 250
    
    private var imagePicker = UIImagePickerController()
    private var albumThumbnailImage : UIImage? = UIImage(named: Util.DEFAULT_IMAGE)
    private var albumThumbnailString: String = Util.DEFAULT_IMAGE

    @IBOutlet weak var familyProfileImageView: EnhancedCircleImageView!
    
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
        self.mottoTextView.delegate = self
    
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    
        let tapGestureBackground = UITapGestureRecognizer(target: self, action: #selector(self.backgroundTapped(_:)))
        self.view.addGestureRecognizer(tapGestureBackground)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count
        return numberOfChars < FamilyProfileViewController.TEXT_VIEW_WORD_LIMIT;
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
    
    @IBAction func updateProfileImage(_ sender: Any) {
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        
        self.present(imagePicker, animated: true, completion:  nil)
    }
    
    
}

extension FamilyProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
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
                self.familyProfileImageView.image = #imageLiteral(resourceName: "tempProfileImage")
                
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

