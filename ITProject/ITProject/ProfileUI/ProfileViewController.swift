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
class ProfileViewController: UIViewController
{
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
	@IBOutlet var dobField: UITextField!
	@IBOutlet var phoneField: UITextField!

	override func viewDidLoad()
	{
		super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
		// Set right bar button as Done to store any changes that user made
		let rightButtonItem = UIBarButtonItem(
			title: "Done",
			style: .done,
			target: self,
			action: #selector(self.DoneButtonTapped)
		)
		navigationItem.rightBarButtonItem = rightButtonItem

		Util.GetImageData(imageUID: self.userInformation.imageUID, UIDExtension: self.userInformation.imageExtension, completion: {
			data in

			if let d = data
			{
				print("get image success : loading data to image")
				self.profilePicture.image = UIImage(data: d)
			}
			else
			{
				print("get image fails : loading data to image")
				self.profilePicture.image = #imageLiteral(resourceName: "item4")
			}
            //set UI layout:
			self.profilePicture.layer.shadowColor = UIColor.selfcGrey.cgColor
			self.profilePicture.layer.shadowOpacity = 0.7
			self.profilePicture.layer.shadowOffset = CGSize(width: 10, height: 10)
			self.profilePicture.layer.shadowRadius = 1
			self.profilePicture.clipsToBounds = false
		})
        
        //set default values to UI :
		self.name.text = self.userInformation.username
		self.relationship.text = self.userInformation.familyRelation
		self.phoneField.text = self.userInformation.phone
		self.dobField.text = self.userInformation.gender?.rawValue
		self.currentRelationship = self.userInformation.familyRelation
		self.currentGender = self.dobField.text
		self.didChangeUserInfo = false
        
		NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        self.name.delegate = self
        self.relationship.delegate = self
        self.phoneField.delegate = self
        self.dobField.delegate = self

	}

	/// Show the keyboard
	/// - Parameter notification: notification
	@objc func keyboardWillShow(notification: NSNotification)
	{
		if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue
		{
			if view.frame.origin.y == 0 {
				UIView.animate(withDuration: 0.25, animations: {
					self.view.frame.origin.y -= keyboardSize.height
				})
			}
		}
	}

	@objc func keyboardWillHide(notification _: NSNotification)
	{
		if view.frame.origin.y != 0 {
			UIView.animate(withDuration: 0.25, animations: {
				self.view.frame.origin.y = 0
			})
		}
	}

	/// Touch the botton to lead to update photos
	/// - Parameter sender: sender
	@IBAction func updateProfileImage(_: Any)
	{
		self.imagePicker.delegate = self
		self.imagePicker.sourceType = .photoLibrary
		self.imagePicker.allowsEditing = true

		present(self.imagePicker, animated: true, completion: nil)
	}

	override func viewWillDisappear(_: Bool)
	{
		if isMovingFromParent, self.didChangeUserInfo
		{
			self.userInformation.userInfoDelegate.didUpdateUserInfo()
			print("view is disappearing from it's parent")
		}
	}

	/// When the button tapped, save all the changes that made by the user
	@objc func DoneButtonTapped()
	{
		let user = Auth.auth().currentUser

		if let u = user
		{
			if u.displayName != self.name.text
			{
				self.didChangeUserInfo = true
				Util.ChangeUserDisplayName(user: u, username: self.name.text!)
			}
		}

		// update DB according to what has changed:
		if self.currentRelationship != self.relationship.text
		{
			self.didChangeUserInfo = true
			DBController.getInstance().updateSpecificField(newValue: self.relationship.text!, fieldName: RegisterDBController.USER_DOCUMENT_FIELD_POSITION, documentUID: user!.uid, collectionName: RegisterDBController.USER_COLLECTION_NAME)
			self.currentRelationship = self.relationship.text
		}
		if self.currentGender != self.dobField.text
		{
            // TO DO here changed to dobfield
			self.didChangeUserInfo = true
			DBController.getInstance().updateSpecificField(newValue: self.dobField.text!, fieldName: RegisterDBController.USER_DOCUMENT_FIELD_GENDER, documentUID: user!.uid, collectionName: RegisterDBController.USER_COLLECTION_NAME)
			self.currentGender = self.dobField.text
		}

		if self.didChangeUserProfile
		{
			self.didChangeUserProfile = false
			self.didChangeUserInfo = true
			if let imageData = self.profilePicture.image?.jpegData(compressionQuality: 1.0),
				let imageString = Util.GenerateUDID()
			{
				Util.ShowActivityIndicator(withStatus: "uploading Profile...")
				Util.UploadFileToServer(data: imageData, metadata: nil, fileName: imageString, fextension: Util.EXTENSION_JPEG, completion: { url in

					if url != nil
					{
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

	@IBAction private func close()
	{
		dismiss(animated: true, completion: nil)
	}
}

extension ProfileViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("textFieldShouldReturn : get called")
        // end editing when user hit return
        textField.endEditing(true)
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        print("textFieldShouldEndEditing : get called")
        return true
    }
}

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
	/// Pick the specific image
	/// - Parameters:
	///   - picker: picker description
	///   - info: info description
	internal func imagePickerController(_: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any])
	{
		// todo : push add/edit photo view
		self.didChangeUserProfile = true
		if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
		{
			self.profilePicture.image =
				editedImage.withRenderingMode(.alwaysOriginal)
		}
		else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
		{
			self.profilePicture.image = originalImage.withRenderingMode(.alwaysOriginal)
		}

		dismiss(animated: true, completion: nil)
	}

	/// delegate function from the UIImagePickerControllerDelegate
	/// called when canceled button pressed, get out of photo library
	/// - Parameter picker: picker
	internal func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
	{
		print("imagePickerController: Did canceled pressed !!")
		picker.dismiss(animated: true, completion: nil)
	}
}
