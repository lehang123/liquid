//
//  NavigationController.swift
//  ITProject
//
//  Created by Gong Lehan on 7/8/19.
//  Copyright © 2019 liquid. All rights reserved.
//

import Firebase
import Foundation
import UIKit

class MainNavigationController: UINavigationController
{
	override func viewDidLoad()
	{
		super.viewDidLoad()
		// Do any additional setup after loading the view.
	}
}

// MARK: - UIViewController Extension

// Put this piece of code anywhere you like
//https://stackoverflow.com/questions/24126678/close-ios-keyboard-by-touching-anywhere-using-swift
extension UIViewController {
    func hideKeyboardWhenTapped() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

// MARK: - UIApplication Extension
extension UIApplication
{
	/// Back to the root controller
	///
	/// - Parameter base: base
	/// - Returns: return to the topest controller
	class func getTopViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController?
	{
		if let nav = base as? UINavigationController
		{
			return self.getTopViewController(base: nav.visibleViewController)
		}
		else if let tab = base as? UITabBarController, let selected = tab.selectedViewController
		{
			return self.getTopViewController(base: selected)
		}
		else if let presented = base?.presentedViewController
		{
			return self.getTopViewController(base: presented)
		}
		return base
	}
}
