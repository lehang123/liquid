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

/// This view controller is mainly to do show all the family information
/// Also shows the comments or description to the family
class FamilyProfileViewController: UIViewController, UITextViewDelegate
{
	// Constants and properties:
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

	override func viewDidLoad()
	{
		super.viewDidLoad()
		// Do any additional setup after loading the view.
		self.setUpView()

		self.familyNameField.text = self.userFamilyInfo.familyName
		self.displayFamilyUID.text = self.userFamilyInfo.familyUID
		self.mottoTextView.text = self.userFamilyInfo.familyMottoText

		// set current ones:
		self.currentFamilyNameField = self.userFamilyInfo.familyName
		self.currentMotto = self.userFamilyInfo.familyMottoText
		self.currentPhotoString = self.userFamilyInfo.familyProfileUID
		self.currentPhotoStringExt = self.userFamilyInfo.familyProfileExtension

		self.didChangeFamilyInfo = false

		// Set right bar button as Done to store any changes that user made
		let rightButtonItem = UIBarButtonItem(
			title: "Done",
			style: .done,
			target: self,
			action: #selector(self.DoneButtonTapped)
		)
		navigationItem.rightBarButtonItem = rightButtonItem
        self.setupDisplayFamilyUID()
	}
    
    private func setupDisplayFamilyUID(){
        displayFamilyUID.layer.addBorder(edge: UIRectEdge.bottom, adjust: CGFloat(0), color: UIColor.lightGray, thickness: 1)
    }

	/// Setting up the view and make it looks better
	private func setUpView()
	{
		Util.GetImageData(imageUID: self.userFamilyInfo.familyProfileUID, UIDExtension: self.userFamilyInfo.familyProfileExtension, completion: {
			data in

			if let d = data
			{
				print("get image success : loading data to image")
				self.familyProfileImageView.image = UIImage(data: d)
			}
			else
			{
				print("get image fails : loading data to image")
                self.familyProfileImageView.image = ImageAsset.default_image.image
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

		NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

		let tapGestureBackground = UITapGestureRecognizer(target: self, action: #selector(self.backgroundTapped(_:)))
		view.addGestureRecognizer(tapGestureBackground)
	}

	/// <#Description#>
	///
	/// - Parameters:
	///   - textView: The text view containing the changes.
	///   - range: The current selection range
	///   - text: The text to insert.
	/// - Returns: true if the old text should be replaced by the new text
	func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool
	{
		let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
		let numberOfChars = newText.count
		return numberOfChars < FamilyProfileViewController.TEXT_VIEW_WORD_LIMIT
	}

	/// <#Description#>
	/// If true, the disappearance of the view is being animated.
	///
	/// - Parameter animated: <#animated description#>
	override func viewWillDisappear(_: Bool)
	{
		if isMovingFromParent, self.didChangeFamilyInfo
		{
			self.userFamilyInfo.familyInfoDelegate.didUpdateFamilyInfo()
			print("view is disappearing from it's parent")
		}
	}

	/// <#Description#>
	/// Save all the changes in the database
	@objc func DoneButtonTapped()
	{
		// commit change to db
		print("FamilyProfileViewController : done button pressed, commit change to db,then dismiss")
		// if user commit change to db
		self.didChangeFamilyInfo = true

		// update according to what has changed:

		if self.currentFamilyNameField != self.familyNameField.text
		{
			DBController.getInstance().updateSpecificField(newValue: self.familyNameField.text!, fieldName: RegisterDBController.FAMILY_DOCUMENT_FIELD_NAME, documentUID: self.displayFamilyUID.text!, collectionName: RegisterDBController.FAMILY_COLLECTION_NAME)
			self.currentFamilyNameField = self.familyNameField.text
		}
		if self.currentMotto != self.mottoTextView.text
		{
			DBController.getInstance().updateSpecificField(newValue: self.mottoTextView.text!, fieldName: RegisterDBController.FAMILY_DOCUMENT_FIELD_MOTTO, documentUID: self.displayFamilyUID.text!, collectionName: RegisterDBController.FAMILY_COLLECTION_NAME)
			self.currentMotto = self.mottoTextView.text
		}

		if self.didChangeFamilyProfile
		{
			self.didChangeFamilyProfile = false
			self.didChangeFamilyInfo = true
			// todo : upload file string to db as well
			if let imageData = self.familyProfileImageView.image?.jpegData(compressionQuality: 1.0), let imageString = Util.GenerateUDID()
			{
				Util.ShowActivityIndicator(withStatus: "uploading Profile...")
				Util.UploadFileToServer(data: imageData, metadata: nil, fileName: imageString, fextension: Util.EXTENSION_JPEG, completion: { url in

					if url != nil
					{
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

	@objc func backgroundTapped(_: UITapGestureRecognizer)
	{
		self.mottoTextView.endEditing(true)
	}

	/// Show the keyboard when the user is editing
	/// - Parameter notification: notification description
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

	/// Hide the keyboard when the user stop editing
	/// - Parameter notification: notification description
	@objc func keyboardWillHide(notification _: NSNotification)
	{
		if view.frame.origin.y != 0 {
			UIView.animate(withDuration: 0.25, animations: {
				self.view.frame.origin.y = 0
			})
		}
	}

	@IBAction func updateProfileImage(_: Any)
	{
		self.imagePicker.delegate = self
		self.imagePicker.sourceType = .photoLibrary
		self.imagePicker.allowsEditing = true
		present(self.imagePicker, animated: true, completion: nil)
	}
}

extension FamilyProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
	/// Pick the specific image
	/// - Parameters:
	///   - picker: picker description
	///   - info: info description
	internal func imagePickerController(_: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any])
	{
		self.didChangeFamilyProfile = true
		if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
		{
			self.familyProfileImageView.image =
				editedImage.withRenderingMode(.alwaysOriginal)
		}
		else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
		{
			self.familyProfileImageView.image = originalImage.withRenderingMode(.alwaysOriginal)
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
