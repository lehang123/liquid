//
//  MainViewController.swift
//  ITProject
//
//  Created by Gong Lehan on 7/8/19.
//  Copyright © 2019 liquid. All rights reserved.
//

import EnhancedCircleImageView
import FirebaseStorage
import Foundation
import UIKit

/// Description
/// This view controller is mainly to do show all the family information
/// Also shows the comments or description to the family
class FamilyProfileViewController: UIViewController, UITextViewDelegate {
    // Constants and properties go here
    private static let TEXT_VIEW_WORD_LIMIT = 150
    private var imagePicker = UIImagePickerController()
    private var didChangeFamilyInfo: Bool = false
    private var didChangeFamilyProfile: Bool = false
    private var currentFamilyNameField: String?
    private var currentMotto: String?
    private var currentPhotoString: String?
    private var currentPhotoStringExt: String?
    var userFamilyInfo: UserFamilyInfo!

    @IBOutlet var familyProfileImageView: EnhancedCircleImageView!
    @IBOutlet var mottoTextView: UITextView!
    @IBOutlet var displayFamilyUID: UILabel!
    @IBOutlet var familyNameField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setUpView()

        familyNameField.text = userFamilyInfo.familyName
        displayFamilyUID.text = userFamilyInfo.familyUID
        mottoTextView.text = userFamilyInfo.familyMottoText

        // set current ones:
        currentFamilyNameField = userFamilyInfo.familyName
        currentMotto = userFamilyInfo.familyMottoText
        currentPhotoString = userFamilyInfo.familyProfileUID
        currentPhotoStringExt = userFamilyInfo.familyProfileExtension

        didChangeFamilyInfo = false

        // Set right bar button as Done to store any changes that user made
        let rightButtonItem = UIBarButtonItem(
            title: "Done",
            style: .done,
            target: self,
            action: #selector(DoneButtonTapped)
        )
        navigationItem.rightBarButtonItem = rightButtonItem
    }

    /// <#Description#>
    /// Setting up the view and make it looks better
    private func setUpView() {
        Util.GetImageData(imageUID: userFamilyInfo.familyProfileUID, UIDExtension: userFamilyInfo.familyProfileExtension, completion: {
            data in

            if let d = data {
                print("get image success : loading data to image")
                self.familyProfileImageView.image = UIImage(data: d)
            } else {
                print("get image fails : loading data to image")
                self.familyProfileImageView.image = #imageLiteral(resourceName: "item4")
            }
            self.familyProfileImageView.layer.shadowColor = UIColor.selfcGrey.cgColor
            self.familyProfileImageView.layer.shadowOpacity = 0.7
            self.familyProfileImageView.layer.shadowOffset = CGSize(width: 10, height: 10)
            self.familyProfileImageView.layer.shadowRadius = 1
            self.familyProfileImageView.clipsToBounds = false
        })

        mottoTextView.layer.borderWidth = 2.0
        mottoTextView.layer.cornerRadius = 8
        mottoTextView.layer.borderColor = UIColor.gray.cgColor
        mottoTextView.delegate = self

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

        let tapGestureBackground = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped(_:)))
        view.addGestureRecognizer(tapGestureBackground)
    }

    /// <#Description#>
    ///
    /// - Parameters:
    ///   - textView: The text view containing the changes.
    ///   - range: The current selection range
    ///   - text: The text to insert.
    /// - Returns: true if the old text should be replaced by the new text
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count
        return numberOfChars < FamilyProfileViewController.TEXT_VIEW_WORD_LIMIT
    }

    /// <#Description#>
    /// If true, the disappearance of the view is being animated.
    ///
    /// - Parameter animated: <#animated description#>
    override func viewWillDisappear(_: Bool) {
        if isMovingFromParent, didChangeFamilyInfo {
            userFamilyInfo.familyInfoDelegate.didUpdateFamilyInfo()
            print("view is disappearing from it's parent")
        }
    }

    /// <#Description#>
    /// Save all the changes in the database
    @objc func DoneButtonTapped() {
        // commit change to db
        print("FamilyProfileViewController : done button pressed, commit change to db,then dismiss")
        // if user commit change to db
        didChangeFamilyInfo = true

        // update according to what has changed:

        if currentFamilyNameField != familyNameField.text {
            DBController.getInstance().updateSpecificField(newValue: familyNameField.text!, fieldName: RegisterDBController.FAMILY_DOCUMENT_FIELD_NAME, documentUID: displayFamilyUID.text!, collectionName: RegisterDBController.FAMILY_COLLECTION_NAME)
            currentFamilyNameField = familyNameField.text
        }
        if currentMotto != mottoTextView.text {
            DBController.getInstance().updateSpecificField(newValue: mottoTextView.text!, fieldName: RegisterDBController.FAMILY_DOCUMENT_FIELD_MOTTO, documentUID: displayFamilyUID.text!, collectionName: RegisterDBController.FAMILY_COLLECTION_NAME)
            currentMotto = mottoTextView.text
        }

        if didChangeFamilyProfile {
            didChangeFamilyProfile = false
            didChangeFamilyInfo = true
            // todo : upload file string to db as well
            if let imageData = self.familyProfileImageView.image?.jpegData(compressionQuality: 1.0), let imageString = Util.GenerateUDID() {
                Util.ShowActivityIndicator(withStatus: "uploading Profile...")
                Util.UploadFileToServer(data: imageData, metadata: nil, fileName: imageString, fextension: Util.EXTENSION_JPEG, completion: { url in

                    if url != nil {
                        //  change  thumbnail path updated in database

                        DBController.getInstance().updateSpecificField(newValue: imageString, fieldName: RegisterDBController.FAMILY_DOCUMENT_FIELD_THUMBNAIL, documentUID: self.displayFamilyUID.text!, collectionName: RegisterDBController.FAMILY_COLLECTION_NAME)
                        DBController.getInstance().updateSpecificField(newValue: Util.EXTENSION_JPEG, fieldName: RegisterDBController.FAMILY_DOCUMENT_FIELD_THUMBNAIL_EXT, documentUID: self.displayFamilyUID.text!, collectionName: RegisterDBController.FAMILY_COLLECTION_NAME)
                    }
                    Util.DismissActivityIndicator()

                }, errorHandler: { e in
                    print("you get error from Thumbnail choose")
                    Util.ShowAlert(title: "Error", message: e!.localizedDescription, action_title: Util.BUTTON_DISMISS, on: self)
                })
            }
        }
    }

    @objc func backgroundTapped(_: UITapGestureRecognizer) {
        mottoTextView.endEditing(true)
    }

    /// Show the keyboard when the user is editing
    /// - Parameter notification: notification description
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if view.frame.origin.y == 0 {
                UIView.animate(withDuration: 0.25, animations: {
                    self.view.frame.origin.y -= keyboardSize.height
                })
            }
        }
    }

    /// Hide the keyboard when the user stop editing
    /// - Parameter notification: notification description
    @objc func keyboardWillHide(notification _: NSNotification) {
        if view.frame.origin.y != 0 {
            UIView.animate(withDuration: 0.25, animations: {
                self.view.frame.origin.y = 0
            })
        }
    }

    @IBAction func updateProfileImage(_: Any) {
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
}

extension FamilyProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    /// Pick the specific image
    /// - Parameters:
    ///   - picker: picker description
    ///   - info: info description
    internal func imagePickerController(_: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        didChangeFamilyProfile = true
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            familyProfileImageView.image =
                editedImage.withRenderingMode(.alwaysOriginal)
        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            familyProfileImageView.image = originalImage.withRenderingMode(.alwaysOriginal)
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
