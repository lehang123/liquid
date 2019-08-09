//
//  ViewController.swift
//  ITProject
//
//  Created by Gong Lehan on 6/8/19.
//  Copyright © 2019 liquid. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class LoginViewController: UIViewController {

    @IBOutlet weak var ID: UITextField!
    @IBOutlet weak var password: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func LoginButtonOnTouch(_ sender: Any) {
        let account: String = ID.text!
        let pw: String = password.text!
        Auth.auth().signIn(withEmail: account, password: pw) { [weak self] user, error in
            guard let strongSelf = self else {
                return
            }

            if error != nil {
                print ("WRONGWRONGWRONGWRONGWRONG ERRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRR")
                let alertController = UIAlertController(title: "Email", message:
                    "", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: .default))
                
                self?.present(alertController, animated: true, completion: nil)
            }
            // ...
            print ("asdasigjiosdjgiosdjgiodsiagasiohgiosdagiosdhioghsioghweiogjiowejgiowejgiowejgioewjiogjweiogjewiojgiowejgiowejgoiwejgiowejgioewjgiojweiogjweiogjewiojgeiowjgioewjg")
            print (strongSelf)
            print (user)
            print (error)
        }
        
        
    }
    
}

