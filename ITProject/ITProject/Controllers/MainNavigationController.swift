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

class MainNavigationController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
}

extension UIApplication {
    /// Back to the root controller
    ///
    /// - Parameter base: base
    /// - Returns: return to the topest controller
    class func getTopViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return getTopViewController(base: nav.visibleViewController)

        } else if let tab = base as? UITabBarController, let selected = tab.selectedViewController {
            return getTopViewController(base: selected)

        } else if let presented = base?.presentedViewController {
            return getTopViewController(base: presented)
        }
        return base
    }
}
