//
//  Util.swift
//  ITProject
//
//  Created by Gong Lehan on 9/8/19.
//  Copyright © 2019 liquid. All rights reserved.
//

import Foundation
import FirebaseStorage

class Util {
    
    public static var ACCOUNT_INCORRECT_TITLE = "Email/Password Incorrect"
    public static var ACCOUNT_INCORRECT_MESSAGE = "Try Again"
    public static var BUTTON_DISMISS = "dismiss"
    public static var CREATE_INCORRECT = "Invalid Email Address"
    public static var CREATE_CORRECT = "Congratulation!"
    public static var CREATE_CORRECT_MESSAGE = "Success!"
    
    
    public static var EXTENSION_JPEG = ".jpg"
    public static var IMAGE_FOLDER = "image/"
    
    public static func GenerateUDID () -> String!{
        let uuid = UUID().uuidString
        return uuid
    }
    
    public static func UploadFileToServer (data: Data, fextension: String, fileName: String) {
        let storageRef = Storage.storage().reference()
        let filefullName = fileName + fextension
        let fullFilePath = GetFullFilePath(fileName: filefullName)
        
        print("file upload to server : " + fullFilePath)
        
        let riversRef = storageRef.child(fullFilePath)
        
        // Upload the file to the path "images/rivers.jpg"
        _ = riversRef.putData(data, metadata: nil) { (metadata, error) in
            guard let metadata = metadata else {
                // Uh-oh, an error occurred!
                print(error!)
                return
            }
            
            
            // Metadata contains file metadata such as size, content-type.
            _ = metadata.size
            // You can also access to download URL after upload.
            riversRef.downloadURL { (url, error) in
                guard url != nil else {
                    // Uh-oh, an error occurred!
                    print(error!)
                    return
                }
            }
        }
    }
    
    public static func GetFolderForFile(fileName:NSString)->String?{
        if ("." + fileName.pathExtension) == (EXTENSION_JPEG) {
            return IMAGE_FOLDER
        }
        return nil
    }
    
    public static func GetFullFilePath(fileName:String)->String{
        return GetFolderForFile(fileName: fileName as NSString)!+fileName
    }
    

}
