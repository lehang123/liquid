//
//  ProfileViewController.swift
//  ITProject
//
//  Created by Erya Wen on 2019/8/11.
//  Copyright © 2019 liquid. All rights reserved.
//

import Firebase
import UIKit
import EnhancedCircleImageView

class ProfileViewController: UIViewController {

    @IBOutlet weak var profilePicture: EnhancedCircleImageView!
    @IBOutlet weak var name: UILabel!
    
    //@IBOutlet weak var userName: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        getName()
        profilePicture.image=#imageLiteral(resourceName: "tempProfileImage")
        
        
    }
    
    @IBAction private func close() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func getName() {
        let user = Auth.auth().currentUser
        if let user = user {
            // The user's ID, unique to the Firebase project.
            // Do NOT use this value to authenticate with your backend server,
            // if you have one. Use getTokenWithCompletion:completion: instead.
            let uid = user.uid
            
            
            name.text = "test"
            
        }
    }
    

}
