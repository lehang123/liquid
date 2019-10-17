//
//  ProfileViewController.swift
//  ITProject
//
//  Created by Erya Wen on 2019/8/11.
//  Copyright © 2019 liquid. All rights reserved.
//

import EnhancedCircleImageView
import Firebase
import DropDown
import UIKit

/// Shows users' info from DB.
class ProfileViewController: UIViewController
{
	// Constants and properties:
	private static let CHANGED_INFO = "Succesfully"
    
	private static let CHANGED_MESSAGE = "The information has changed"
    
    ///for keyboard:
	private var keyboardSize: CGRect!
    
    ///for image:
	private var imagePicker = UIImagePickerController()
    ///for DOB:
    private var datePicker  = UIDatePicker()
    
    private(set) var currentRelationship: String?, currentName:String?, currentDOB: Date?;
    
    private let dateFormatter : DateFormatter = DateFormatter();
    
	var userInformation: UserInfo!
    ///flag variables to notice other UIs that data has been altered:
	private(set) var didChangeUserInfo: Bool = false, didChangeUserProfile: Bool = false

    //UI Fields:
	@IBOutlet var profilePicture: EnhancedCircleImageView!
	@IBOutlet var name: UITextField!
	@IBOutlet var relationship: UITextField!
	@IBOutlet var DOBField: UITextField!
//	@IBOutlet var gender: UITextField!
    @IBOutlet var genderButton: UIButton!
    
    
    
    ///  Set right bar button as Done to store any changes that user made
    func setDoneButton(){
       
        navigationItem.rightBarButtonItem =  UIBarButtonItem(
                   title: "Done",
                   style: .done,
                   target: self,
                   action: #selector(self.DoneButtonTapped)
               )
    }
    
    /// Get Image Data from storage, then set it to UI .
    func setProfilePicture(){
        Util.GetImageData(imageUID: self.userInformation.imageUID, UIDExtension: self.userInformation.imageExtension, completion: {
            data in
            // image exists:
            if let data = data
            {
                print("get image success : loading data to image")
                self.profilePicture.image = UIImage(data: data)
            }
            // image doesn't exist:
            else
            {
                print("get image fails : loading data to image")
                self.profilePicture.image = #imageLiteral(resourceName: "item4")
            }
            //set profile picture UI layout:
            self.profilePicture.layer.shadowColor = UIColor.selfcGrey.cgColor
            self.profilePicture.layer.shadowOpacity = 0.7
            self.profilePicture.layer.shadowOffset = CGSize(width: 10, height: 10)
            self.profilePicture.layer.shadowRadius = 1
            self.profilePicture.clipsToBounds = false
        })
    }
    ///init date formatter:
    func setDateFormatter(){
        
        dateFormatter.dateFormat = "dd/MM/yyyy"
        
    }
    ///fills in UI fields with most recent  values:
    func populateData(){
        //set default values to UI :
        self.name.text = self.userInformation.username
        self.relationship.text = self.userInformation.familyRelation
        
        if(self.userInformation.gender == ""){
            self.genderButton.setTitle("  Gender", for: .normal)
            self.genderButton.setTitleColor(UIColor.lightGray.withAlphaComponent(0.8), for: .normal)
        } else{
        self.genderButton.setTitle(self.userInformation.gender, for: .normal)
            self.genderButton.setTitleColor(UIColor.black, for: .normal)
        }
       
        
        let dob = dateFormatter.string(from:  self.userInformation.dateOfBirth ?? Date())
        self.DOBField.text = dob
        self.datePicker.date = dateFormatter.date(from: dob)!
       
        print("NAME IN PROFILE", self.userInformation.username)
               
        self.didChangeUserInfo = false
        //deprecated:
        //set current vals to be checked later:
        //self.currentRelationship = self.userInformation.familyRelation
        //self.currentDOB = dateFormatter.date(from: dob)!
        //        self.currentName = self.userInformation.username
    }
    
    let chooseDropDown = DropDown()
    
    lazy var dropDowns: [DropDown] = {
        return [
            self.chooseDropDown,
        ]
    }()
    @IBAction func genderButton(_ sender: Any) {
        chooseDropDown.show()
    }
    
    func setupChooseDropDown() {
        chooseDropDown.anchorView = genderButton
        
        // By default, the dropdown will have its origin on the top left corner of its anchor view
        // So it will come over the anchor view and hide it completely
        // If you want to have the dropdown underneath your anchor view, you can do this:
        chooseDropDown.bottomOffset = CGPoint(x: 0, y: genderButton.bounds.height)
        
        // You can also use localizationKeysDataSource instead. Check the docs.
        chooseDropDown.dataSource = [
            "Female",
            "Male",
            "Other",
            "Prefer not say"
        ]
        
        // Action triggered on selection
        chooseDropDown.selectionAction = { [weak self] (index, item) in
            let sex = "  " + item
            self?.genderButton.setTitle(sex, for: .normal)
            self?.genderButton.setTitleColor(UIColor.black, for: .normal)
        }
        
    }
    
    /// configures a date picker for choosing date of birth later on.
    func setDatePicker(){
        // init dob's date field:
        //todo: pick Locale! AU or ID?
        datePicker.locale = Locale(identifier: "id")
        datePicker.datePickerMode  = .date
        
        DOBField.inputView = datePicker
        datePicker.addTarget(self, action: #selector(ProfileViewController.dateChanged(datePicker:)), for: .valueChanged)
        //dob edge case: if tap somewhere else, end editing session:
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ProfileViewController.viewTapped(gestureRecognizer:)))
        self.datePicker.maximumDate = Date()
        view.addGestureRecognizer(tapGesture)
    }
	override func viewDidLoad()
	{
		super.viewDidLoad()
        //set layout:
        self.hideKeyboardWhenTapped()
        
		
        self.setProfilePicture()
        self.setDoneButton()
        self.setDateFormatter()
        self.setDatePicker()
        
        
        //fill in default data:
        self.populateData()
        self.setupChooseDropDown()
        self.genderButton.layer.cornerRadius = 5
        self.genderButton.layer.borderWidth = 1
        self.genderButton.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.3).cgColor
        
        
      
//        print("DOB IS " ,  self.userInformation.dateOfBirth )
//        print("date ",  self.datePicker.date  )
       
       //handle keyboard observer:
		NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        self.setDelegate()
	}
    
    func setDelegate(){
        self.name.delegate = self
        self.relationship.delegate = self
       // self.gender.delegate = self
        self.DOBField.delegate = self
    }
    
    /// ends editing on DOB field when screen is tapped.
    /// - Parameter gestureRecognizer: listening  to tap gesture
    @objc func viewTapped(gestureRecognizer:UITapGestureRecognizer){
        view.endEditing(true)
    }
    /// handles changing date field.
    /// - Parameter datePicker: datePicker UI
    @objc func dateChanged(datePicker : UIDatePicker){
        self.DOBField.text = self.dateFormatter.string(from: datePicker.date )
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

	/// Touch the botton to trigger  update photos
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
    ///1st version: update when change, but total: 3x updates. MAYBE CAN USE BATCH.
//	@objc func DoneButtonTapped()
//	{
//        //end editing first:
//        view.endEditing(true)
//
//		let user = Auth.auth().currentUser
//
//		// update DB according to what has changed:
//
//        if self.currentName != self.name.text
//        {
//            self.didChangeUserInfo = true
//
//            DBController.getInstance().updateSpecificField(newValue: self.name.text!, fieldName: RegisterDBController.USER_DOCUMENT_FIELD_NAME, documentUID: user!.uid, collectionName: RegisterDBController.USER_COLLECTION_NAME)
//            self.currentName = self.name.text
//        }
//
//		if self.currentRelationship != self.relationship.text
//		{
//			self.didChangeUserInfo = true
//			DBController.getInstance().updateSpecificField(newValue: self.relationship.text!, fieldName: RegisterDBController.USER_DOCUMENT_FIELD_POSITION, documentUID: user!.uid, collectionName: RegisterDBController.USER_COLLECTION_NAME)
//			self.currentRelationship = self.relationship.text
//		}
//
//        if self.currentDOB != self.datePicker.date
//		{
////            print("BEFORE currentDOB", self.currentDOB, "DATEPICKER",self.datePicker.date )
//			self.didChangeUserInfo = true
//            DBController.getInstance().updateSpecificField(newValue: self.datePicker.date, fieldName: RegisterDBController.USER_DOCUMENT_FIELD_DATE_OF_BIRTH, documentUID: user!.uid, collectionName: RegisterDBController.USER_COLLECTION_NAME)
//            self.currentDOB = self.datePicker.date
//
//		}
//        self.commitUIChange();
//
//
//	}
    /// When the button tapped, save all the changes that made by the user
    ///2nd version: always update, but only 1x
        @objc func DoneButtonTapped()
        {
            //end editing date field first:
            view.endEditing(true)
            var genderText = ""
            if !(self.genderButton.title(for: .normal) == "  Gender"){
                genderText = self.genderButton.title(for: .normal)!
            }
            
            //update to DB:
            self.didChangeUserInfo = true
            DBController
                .getInstance()
                .getDB()
                .collection(RegisterDBController.USER_COLLECTION_NAME)
                .document( Auth.auth().currentUser!.uid)
                .updateData(
                    [
                        RegisterDBController.USER_DOCUMENT_FIELD_DATE_OF_BIRTH : self.datePicker.date,
                        RegisterDBController.USER_DOCUMENT_FIELD_NAME : self.name.text!,
                        RegisterDBController.USER_DOCUMENT_FIELD_POSITION : self.relationship.text!,
                        RegisterDBController.USER_DOCUMENT_FIELD_GENDER : genderText,
                    ])
            
            self.commitUIChange();
        }
      
    
    func commitUIChange(){
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
                        //todo : delete old photo in db:
                        
                        // change photo url in db:
                        RegisterDBController.getInstance().UploadUserProfilePicture(imagePath: (url?.deletingPathExtension().lastPathComponent)!  , imageExt: Util.EXTENSION_JPEG)
                    }
                    Util.DismissActivityIndicator()
                    self.navigationController?.popToRootViewController(animated: true)
                }, errorHandler: { e in
                    print("you get error from Thumbnail choose")
                    Util.ShowAlert(title: "Error", message: e!.localizedDescription, action_title: Util.BUTTON_DISMISS, on: self)
                })
            }
        }else {
            self.navigationController?.popToRootViewController(animated: true)
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
