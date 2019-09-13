//
//  NavigationController.swift
//  ITProject
//
//  Created by Gong Lehan on 7/8/19.
//  Copyright © 2019 liquid. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class MainNavigationController :UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // login()
    }
    
    func login(){
        /** @fn addAuthStateDidChangeListener:
         @brief Registers a block as an "auth state did change" listener. To be invoked when:
         
         + The block is registered as a listener,
         + A user with a different UID from the current user has signed in, or
         + The current user has signed out.
         
         @param listener The block to be invoked. The block is always invoked asynchronously on the main
         thread, even for it's initial invocation after having been added as a listener.
         
         @remarks The block is invoked immediately after adding it according to it's standard invocation
         semantics, asynchronously on the main thread. Users should pay special attention to
         making sure the block does not inadvertently retain objects which should not be retained by
         the long-lived block. The block itself will be retained by FIRAuth until it is
         unregistered or until the FIRAuth instance is otherwise deallocated.
         
         @return A handle useful for manually unregistering the block as a listener.
         */
        Auth.auth().addStateDidChangeListener { (auth, user) in
            // when current user is sign out
            
            if auth.currentUser == nil {
                self.askForLogin()
            }else{
                self.loadName()

                print("ELSE I'm here : " + (user?.email)!)
                //start caching:
                CacheHandler.getInstance().cacheUserAndFamily()

                print("Listener get called ")
            }
        }
    }
    

    private func askForLogin(){
        guard let VC1 = UIApplication.getTopViewController()?.storyboard!.instantiateViewController(withIdentifier: "LoginViewController") else { return }
        let navController = UINavigationController(rootViewController: VC1) // Creating a navigation controller with VC1 at the root of the navigation stack.
        self.present(navController, animated:true, completion: nil)
    }

    func loadName() {
        let user = Auth.auth().currentUser

        if let user = user {
            let uid = user.uid
            DBController.getInstance().getDocumentFromCollection(collectionName: RegisterDBController.USER_COLLECTION_NAME, documentUID: uid){
                (document, error) in
                if let document = document, document.exists {
                    //_ = document.data().map(String.init(describing:)) ?? "nil"
                    DispatchQueue.main.async {
                        let n = (document.data()!["name"])
                        CacheHandler.getInstance().setCache(obj: n as AnyObject, forKey: "name" as AnyObject )
                    }
                }
            }
        }
    }
}

extension UIApplication {
    
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
