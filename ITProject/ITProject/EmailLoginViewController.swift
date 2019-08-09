//
//  EmailLoginViewController.swift
//  ITProject
//
//  Created by 陳信宏保佑🙏 on 2019/8/7.
//  Copyright © 2019 liquid. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class EmailLoginViewController : UIViewController {
    
    @IBOutlet weak var emailAddress: UITextField!
    @IBOutlet weak var password: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func CreateButtonOnTouch(_ sender: Any) {
                let email: String = emailAddress.text!
                let pw: String = password.text!
                Auth.auth().createUser(withEmail: email, password: pw) {
                    authResult, error in
                }
    }
    
    
    



}
