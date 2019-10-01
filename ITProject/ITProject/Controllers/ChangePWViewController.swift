//
//  ChangePWViewController.swift
//  ITProject
//
//  Created by Zhu Chenghong on 2019/8/16.
//  Copyright © 2019 liquid. All rights reserved.
//

import Firebase
import Foundation
import UIKit

/// This view controller is mainly for user to change the password
class ChangePasswordViewController: UIViewController
{
	// Constants and properties go here
	private static let PASSWORD_INVALID = "The original password is invalid"
	private static let PASSWORD_LENGTH_NOT_ENOUGH = "Minimum length is 8"
	private static let CONFIRMED_INCORRECT_WRONG = "Mismatch password, please try again"
	private static let ACCOUNT_INCORRECT_MESSAGE = "Please try again"
	private static let CREATE_CORRECT = "Congratulation!"
	private static let PASSWORD_CHANGE_SUCCESS = "Password has been changed."

	@IBOutlet var originalPW: UITextField!
	@IBOutlet var newPW: UITextField!
	@IBOutlet var confirmedPassword: UITextField!

	override func viewDidLoad()
	{
		super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        // Check if the user is typing
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

        self.originalPW.delegate = self
        self.newPW.delegate = self
        self.confirmedPassword.delegate = self
	}
    
    /// Show the keyboard
    /// - Parameter notification: notification
    @objc func keyboardWillShow(notification: NSNotification)
    {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue
        {
            if self.confirmedPassword.isEditing {
                if view.frame.origin.y == 0 {
                    UIView.animate(withDuration: 0.25, animations: {
                        self.view.frame.origin.y -= keyboardSize.height
                    })
                }
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
    
	/// Check if the entered passwords are the same
	/// If they are satisfied, then update it to databse
	/// - Parameter sender: Clike the confirm bottom
	@IBAction func Confirm(_: Any)
	{
		// make sure both new and old passwords are at least 8 characters.
		if self.newPW.text!.count < 8 {
			Util.ShowAlert(title: ChangePasswordViewController.PASSWORD_LENGTH_NOT_ENOUGH,
			               message: ChangePasswordViewController.ACCOUNT_INCORRECT_MESSAGE,
			               action_title: Util.BUTTON_DISMISS,
			               on: self)
		}

		if self.originalPW.text!.count < 8 {
			Util.ShowAlert(title: ChangePasswordViewController.PASSWORD_INVALID,
			               message: ChangePasswordViewController.ACCOUNT_INCORRECT_MESSAGE,
			               action_title: Util.BUTTON_DISMISS,
			               on: self)
		}

		// Check if the typed passwords are the same
		if self.newPW.text == self.confirmedPassword.text
		{
			let user = Auth.auth().currentUser
			let credential: AuthCredential = EmailAuthProvider.credential(withEmail: (user?.email)!, password: self.originalPW.text!)

			// Prompt the user to re-provide their sign-in credentials
			user?.reauthenticate(with: credential, completion: { _, error in
				if error != nil
				{
					// An error happened.
					Util.ShowAlert(title: error!.localizedDescription, message: ChangePasswordViewController.ACCOUNT_INCORRECT_MESSAGE, action_title: Util.BUTTON_DISMISS, on: self)
				}
				else
				{
					// User re-authenticated.
					self.updatePassword(newPW: self.newPW.text!)
				}
			})
		}
		else
		{
			Util.ShowAlert(title: ChangePasswordViewController.CONFIRMED_INCORRECT_WRONG,
			               message: ChangePasswordViewController.ACCOUNT_INCORRECT_MESSAGE,
			               action_title: Util.BUTTON_DISMISS,
			               on: self)
		}
	}

	/// Update the password to the databse
	/// - Parameter newPW: the new password that user want to use
	func updatePassword(newPW: String)
	{
		Auth.auth().currentUser?.updatePassword(to: newPW)
		{ error in
			if error == nil
			{
				Util.ShowAlert(title: ChangePasswordViewController.CREATE_CORRECT, message: ChangePasswordViewController.PASSWORD_CHANGE_SUCCESS, action_title: ChangePasswordViewController.CREATE_CORRECT, on: self)
				{
					self.navigationController?.popToRootViewController(animated: true)
				}
			}
			else
			{
				Util.ShowAlert(title: error!.localizedDescription,
				               message: ChangePasswordViewController.ACCOUNT_INCORRECT_MESSAGE, action_title: Util.BUTTON_DISMISS,
				               on: self)
			}
		}
	}
}

extension ChangePasswordViewController: UITextFieldDelegate{
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
