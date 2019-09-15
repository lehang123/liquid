//
//  ViewController.swift
//  ITProject/Users/zhuchenghong/Desktop/liquid/ITProject/ITProject/Controllers/ChangePWViewController.swift
//
//  Created by Gong Lehan on 6/8/19.
//  Copyright © 2019 liquid. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class LoginViewController: UIViewController {
    
    private static let ACCOUNT_INCORRECT_TITLE = "Email/Password Incorrect"
    private static let ACCOUNT_INCORRECT_MESSAGE = "Try Again"

    @IBOutlet weak var ID: UITextField!
    @IBOutlet weak var password: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        let tapGestureBackground = UITapGestureRecognizer(target: self, action: #selector(self.backgroundTapped(_:)))
        self.view.addGestureRecognizer(tapGestureBackground)
    }
    
    @objc func backgroundTapped(_ sender: UITapGestureRecognizer)
    {
        self.ID.endEditing(true)
        self.password.endEditing(true)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {

            if password.isEditing{
                
                if self.view.frame.origin.y == 0 {
                    UIView.animate(withDuration: 0.25, animations: {
                        self.view.frame.origin.y -= keyboardSize.height
                    })
                }
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            UIView.animate(withDuration: 0.25, animations: {
                 self.view.frame.origin.y = 0
            })
        }
    }

    @IBAction func LoginButtonOnTouch(_ sender: Any) {
        let account: String = ID.text!
        let pw: String = password.text!
        Util.ShowActivityIndicator(withStatus: "login...")
        Auth.auth().signIn(withEmail: account, password: pw) { [weak self] user, error in 
            if error != nil {
                Util.DismissActivityIndicator()
                let alertController = UIAlertController(title: LoginViewController.ACCOUNT_INCORRECT_TITLE, message:
                    LoginViewController.ACCOUNT_INCORRECT_MESSAGE, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: Util.BUTTON_DISMISS, style: .default))
                self?.present(alertController, animated: true, completion: nil)
            } else {
                Util.DismissActivityIndicator()

                self?.dismiss(animated: true, completion: nil)
                
            }
        }
    }
    

    
//    private func getUserInfo(usrResult : AuthDataResult){
//        let profilePhotoUrl = usrResult.user.photoURL
//        let username = usrResult.user.displayName
//
//    }

    public func tFunction(){
//        // test for upload file
//        Util.downloadImage(from:URL(string: "https://cdn.arstechnica.net/wp-content/uploads/2018/06/macOS-Mojave-Dynamic-Wallpaper-transition.jpg")!){
//            (data, url, error) in
//            Util.UploadFileToServer(data: data!, metadata: nil, fileFullName: (Util.GenerateUDID() + Util.EXTENSION_JPEG), completion:{(url) in
//                print ("tFunction : upload file successful, here is the url : ")
//                print(url!)
//            })
//        }
//        // test for download file
//        Util.DownloadFileFromServer(fileFullPath: "images/2E61DCE8-B133-4936-BDC7-E90FB4199B21.zip", completion: {(fileUrl) in
//            print("file download and unzip success :" + fileUrl!.absoluteString)
//        })
        
//        Util.GetDataFromLocalFile(filename: "152B6B38-79F5-45B2-8126-CE9FB9854D8E", fextension: ".jpg")
    }
    
    public func testFunction(){
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: documentsURL.appendingPathComponent(Util.IMAGE_FOLDER), includingPropertiesForKeys: nil)
            // process files
            print(fileURLs)
        } catch {
            print("Error while enumerating files \(documentsURL.path): \(error.localizedDescription)")
        }
    }
}

