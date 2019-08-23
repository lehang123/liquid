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
        
        //self.tableView.delgate = self
    }
    
    @IBAction private func close() {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    // Get the name of the user.
    func getName() {
        let user = Auth.auth().currentUser
        print (CacheHandler.getInstance().getCache(forKey: "name" as AnyObject))
        self.name.text = (CacheHandler.getInstance().getCache(forKey: "name" as AnyObject) as! String)

    }
    

}

