//
//  ViewController.swift
//  ITProject/Users/zhuchenghong/Desktop/liquid/ITProject/ITProject/Controllers/ChangePWViewController.swift
//
//  Created by Gong Lehan on 6/8/19.
//  Copyright © 2019 liquid. All rights reserved.
//

import Firebase
import Foundation
import UIKit

/// <#Description#>
/// This view is mainly for user to log in
class LoginViewController: UIViewController
{
	// Constants and properties go here
	private static let ACCOUNT_INCORRECT_TITLE = "Email/Password Incorrect"
	private static let ACCOUNT_INCORRECT_MESSAGE = "Try Again"

	@IBOutlet var ID: UITextField!
	@IBOutlet var password: UITextField!

	override func viewDidLoad()
	{
		super.viewDidLoad()
		// Do any additional setup after loading the view.
		NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

		let tapGestureBackground = UITapGestureRecognizer(target: self, action: #selector(self.backgroundTapped(_:)))
		view.addGestureRecognizer(tapGestureBackground)
	}

	/// Detect the user tapped on the background
	/// - Parameter sender: sender
	@objc func backgroundTapped(_: UITapGestureRecognizer)
	{
		self.ID.endEditing(true)
		self.password.endEditing(true)
	}

	/// Show the keyboard to the user
	/// - Parameter notification: notification
	@objc func keyboardWillShow(notification: NSNotification)
	{
		if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue
		{
			if self.password.isEditing
			{
				if view.frame.origin.y == 0 {
					UIView.animate(withDuration: 0.25, animations: {
						self.view.frame.origin.y -= keyboardSize.height
					})
				}
			}
		}
	}

	/// Hide the keyboard
	/// - Parameter notification: notification
	@objc func keyboardWillHide(notification _: NSNotification)
	{
		if view.frame.origin.y != 0 {
			UIView.animate(withDuration: 0.25, animations: {
				self.view.frame.origin.y = 0
			})
		}
	}

	/// When user touched the buttom to log in
	/// - Parameter sender: sender
	@IBAction func LoginButtonOnTouch(_: Any)
	{
		let account: String = self.ID.text!
		let pw: String = self.password.text!
		Util.ShowActivityIndicator(withStatus: "login...")
		Auth.auth().signIn(withEmail: account, password: pw)
		{ [weak self] _, error in
			if error != nil
			{
				Util.DismissActivityIndicator()
				let alertController = UIAlertController(title: LoginViewController.ACCOUNT_INCORRECT_TITLE, message:
					LoginViewController.ACCOUNT_INCORRECT_MESSAGE, preferredStyle: .alert)
				alertController.addAction(UIAlertAction(title: Util.BUTTON_DISMISS, style: .default))
				self?.present(alertController, animated: true, completion: nil)
			}
			else
			{
				Util.DismissActivityIndicator()

				self?.dismiss(animated: true, completion: nil)
			}
		}
	}
}
