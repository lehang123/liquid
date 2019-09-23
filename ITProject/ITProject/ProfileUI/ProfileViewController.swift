//
//  ProfileViewController.swift
//  ITProject
//
//  Created by Erya Wen on 2019/8/11.
//  Copyright © 2019 liquid. All rights reserved.
//

import EnhancedCircleImageView
import Firebase
import UIKit

/// <#Description#>
/// Shows users' info from DB.
class ProfileViewController: UIViewController {
    // Constants and properties:
    private static let CHANGED_INFO = "Succesfully"
    private static let CHANGED_MESSAGE = "The information has changed"
    private var keyboardSize: CGRect!
    private var imagePicker = UIImagePickerController()
    var currentRelationship: String?
    var currentGender: String?
    var userInformation: UserInfo!
    var didChangeUserInfo: Bool = false
    var didChangeUserProfile: Bool = false

    @IBOutlet var profilePicture: EnhancedCircleImageView!
    @IBOutlet var name: UITextField!
    @IBOutlet var relationship: UITextField!
    @IBOutlet var genderField: UITextField!
    @IBOutlet var phoneField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set right bar button as Done to store any changes that user made
        let rightButtonItem = UIBarButtonItem(
            title: "Done",
            style: .done,
            target: self,
            action: #selector(DoneButtonTapped)
        )
        navigationItem.rightBarButtonItem = rightButtonItem

        Util.GetImageData(imageUID: userInformation.imageUID, UIDExtension: userInformation.imageExtension, completion: {
            data in

            if let d = data {
                print("get image success : loading data to image")
                self.profilePicture.image = UIImage(data: d)
            } else {
                print("get image fails : loading data to image")
                self.profilePicture.image = #imageLiteral(resourceName: "item4")
            }
            self.profilePicture.layer.shadowColor = UIColor.selfcGrey.cgColor
            self.profilePicture.layer.shadowOpacity = 0.7
            self.profilePicture.layer.shadowOffset = CGSize(width: 10, height: 10)
            self.profilePicture.layer.shadowRadius = 1
            self.profilePicture.clipsToBounds = false
        })

        name.text = userInformation.username
        relationship.text = userInformation.familyRelation
        phoneField.text = userInformation.phone
        genderField.text = userInformation.gender?.rawValue

        currentRelationship = userInformation.familyRelation
        currentGender = genderField.text

        didChangeUserInfo = false

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

        // but to stop editing when the user taps anywhere on the view, add this gesture recogniser
        let tapGestureBackground = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped(_:)))
        view.addGestureRecognizer(tapGestureBackground)
    }

    /// hide the keyboard
    /// - Parameter sender: tap the background
    @objc func backgroundTapped(_: UITapGestureRecognizer) {
        name.endEditing(true)
        relationship.endEditing(true)
        phoneField.endEditing(true)
        genderField.endEditing(true)
    }

    /// Show the keyboard
    /// - Parameter notification: notification
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if view.frame.origin.y == 0 {
                UIView.animate(withDuration: 0.25, animations: {
                    self.view.frame.origin.y -= keyboardSize.height
                })
            }
        }
    }

    @objc func keyboardWillHide(notification _: NSNotification) {
        if view.frame.origin.y != 0 {
            UIView.animate(withDuration: 0.25, animations: {
                self.view.frame.origin.y = 0
            })
        }
    }

    /// Touch the botton to lead to update photos
    /// - Parameter sender: sender
    @IBAction func updateProfileImage(_: Any) {
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true

        present(imagePicker, animated: true, completion: nil)
    }

    override func viewWillDisappear(_: Bool) {
        if isMovingFromParent, didChangeUserInfo {
            userInformation.userInfoDelegate.didUpdateUserInfo()
            print("view is disappearing from it's parent")
        }
    }

    /// When the button tapped, save all the changes that made by the user
    @objc func DoneButtonTapped() {
        let user = Auth.auth().currentUser

        if let u = user {
            if u.displayName != name.text {
                didChangeUserInfo = true
                Util.ChangeUserDisplayName(user: u, username: name.text!)
            }
        }

        // update DB according to what has changed:
        if currentRelationship != relationship.text {
            didChangeUserInfo = true
            DBController.getInstance().updateSpecificField(newValue: relationship.text!, fieldName: RegisterDBController.USER_DOCUMENT_FIELD_POSITION, documentUID: user!.uid, collectionName: RegisterDBController.USER_COLLECTION_NAME)
            currentRelationship = relationship.text
        }
        if currentGender != genderField.text {
            didChangeUserInfo = true
            DBController.getInstance().updateSpecificField(newValue: genderField.text!, fieldName: RegisterDBController.USER_DOCUMENT_FIELD_GENDER, documentUID: user!.uid, collectionName: RegisterDBController.USER_COLLECTION_NAME)
            currentGender = genderField.text
        }

        if didChangeUserProfile {
            didChangeUserProfile = false
            didChangeUserInfo = true
            if let imageData = self.profilePicture.image?.jpegData(compressionQuality: 1.0),
                let imageString = Util.GenerateUDID() {
                Util.ShowActivityIndicator(withStatus: "uploading Profile...")
                Util.UploadFileToServer(data: imageData, metadata: nil, fileName: imageString, fextension: Util.EXTENSION_JPEG, completion: { url in

                    if url != nil {
                        // change photo url in auth service
                        Util.ChangeUserPhotoURL(imagePath: imageString, ext: Util.EXTENSION_JPEG)
                    }
                    Util.DismissActivityIndicator()
                }, errorHandler: { e in
                    print("you get error from Thumbnail choose")
                    Util.ShowAlert(title: "Error", message: e!.localizedDescription, action_title: Util.BUTTON_DISMISS, on: self)
                })
            }
        }
    }

    @IBAction private func close() {
        dismiss(animated: true, completion: nil)
    }
}

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    /// Pick the specific image
    /// - Parameters:
    ///   - picker: picker description
    ///   - info: info description
    internal func imagePickerController(_: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        // todo : push add/edit photo view
        didChangeUserProfile = true
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            profilePicture.image =
                editedImage.withRenderingMode(.alwaysOriginal)
        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            profilePicture.image = originalImage.withRenderingMode(.alwaysOriginal)
        }

        dismiss(animated: true, completion: nil)
    }

    /// delegate function from the UIImagePickerControllerDelegate
    /// called when canceled button pressed, get out of photo library
    /// - Parameter picker: picker
    internal func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("imagePickerController: Did canceled pressed !!")
        picker.dismiss(animated: true, completion: nil)
    }
}
