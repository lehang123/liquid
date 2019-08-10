//
//  Util.swift
//  ITProject
//
//  Created by Gong Lehan on 9/8/19.
//  Copyright © 2019 liquid. All rights reserved.
//

import Foundation
import FirebaseStorage
import SVProgressHUD

class Util {
    public static let BUTTON_DISMISS = "dismiss"
    
    public static let EXTENSION_JPEG = ".jpg"
    public static let IMAGE_FOLDER = "image/"
    public static let TMP_FOLDER = "tmp/"
    public static let FIREBASE_STORAGE_URL = "gs://liquid-248305.appspot.com/"
    
    public static func GenerateUDID () -> String!{
        let uuid = UUID().uuidString
        return uuid
    }
    
    public static func PrepareDocumentFolder (){
        CreateTmpFolder()
        CreateImageFolder()
    }
    
    public static func UploadFileToServer (data: Data, fextension: String, fileName: String) {
        let storageRef = Storage.storage().reference()
        let filefullName = fileName + fextension
        let fullFilePath = GetFullFilePath(fileName: filefullName)
        
        print("file upload to server : " + fullFilePath)
        
        let sRef = storageRef.child(fullFilePath)
        
        // Upload the file to the path "images/rivers.jpg"
        _ = sRef.putData(data, metadata: nil) { (metadata, error) in
            guard let metadata = metadata else {
                // Uh-oh, an error occurred!
                print(error!)
                return
            }
            
            
            // Metadata contains file metadata such as size, content-type.
            _ = metadata.size
            // You can also access to download URL after upload.
            sRef.downloadURL { (url, error) in
                guard url != nil else {
                    // Uh-oh, an error occurred!
                    print(error!)
                    return
                }
            }
        }
    }
    
    /* test image link   "795C8939-982E-40C8-AE2D-610A6EBA5866.jpg"
     error solver error 518:
     https://stackoverflow.com/questions/37470266/error-when-downloading-from-firebase-storage
    */
    public static func DownloadFileFromServer (fileName:String){
        let fileFullPath = GetFullFilePath(fileName: fileName)
        print("DownloadFileFromServer :file path" + fileFullPath)
        let gsReference = Storage.storage().reference(forURL: FIREBASE_STORAGE_URL + fileFullPath)
        let localURL = URL(fileURLWithPath: GetImageDirectory())
      
        // Download to the local filesystem
        _ = gsReference.write(toFile: localURL) { url, error in
            if let error = error {
                // Uh-oh, an error occurred!
                print("DownloadFileFromServer fail")
                print(error)
            } else {
                // Local file URL for "images/island.jpg" is returned
                print("DownloadFileFromServer success with url :")
                print(url!)
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

    /* DocumentDirectory for the app that allows us to do read and write */
    public static func GetDocumentsDirectory()->String{
        return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    }
    
    public static func GetImageDirectory()->String{
        return GetDocumentsDirectory() + "/" + IMAGE_FOLDER
    }
    
    public static func GetTmpDirectory()->String{
        return GetDocumentsDirectory() + "/" + TMP_FOLDER
    }
    
    public static func CreateFolderInDocuments(folderName:String){
        var isDir : ObjCBool = false
        if !FileManager.default.fileExists(atPath: folderName, isDirectory:&isDir) {
            do {
                try FileManager.default.createDirectory(atPath: folderName, withIntermediateDirectories: true, attributes: nil)
                print("CreateFolderInDocuments: Created " + folderName + " success : "
                    + String(DoesDirectoryExist(fullPath: folderName)))
            } catch {
                print(error.localizedDescription);
            }
        }else{
            print("CreateFolderInDocuments: Folder already exist, don't need to create ")
        }
    }
    
    public static func CreateImageFolder(){
        let dataPath = GetDocumentsDirectory() + "/" + IMAGE_FOLDER
        CreateFolderInDocuments(folderName: dataPath)
    }
    
    public static func CreateTmpFolder(){
        
        let dataPath = GetDocumentsDirectory() + "/" + TMP_FOLDER
        CreateFolderInDocuments(folderName: dataPath)
    }
    
    public static func DoesFileExist(fullPath:String)->Bool{
        return DoesFileExist(fullPath: fullPath, checkIsDirectory: false)
    }
    
    public static func DoesDirectoryExist(fullPath:String)->Bool{
        return DoesFileExist(fullPath: fullPath, checkIsDirectory: true)
    }
    
    public static func DoesFileExist(fullPath:String, checkIsDirectory:Bool)-> Bool{
        let fileManager = FileManager.default
        var isDir : ObjCBool = false
        if fileManager.fileExists(atPath: fullPath, isDirectory:&isDir) {
            
            if isDir.boolValue {
                print("DoesFileExist: file exists and is a directory")
                if checkIsDirectory{
                    return true
                }else{
                    return false
                }
            } else {
                print("DoesFileExist: file exists and is not a directory")
                if checkIsDirectory{
                    return false
                }else{
                    return true
                }
            }
        } else {
            print("DoesFileExist: file does not exist")
            return false
        }
    }
    
    public static func UserInitThread (work: @escaping (() -> Void) = {}){
        DispatchQueue(label: "working_queue", qos: .userInitiated).async {
            work()
        }
    }
    
    public static func ShowAlert (title: String,
                                  message: String,
                                  action_title: String,
                                  on: UIViewController,
                                  aaction: @escaping (() -> Void) = {}) {
        /*present alert always on UI/main thread */
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: action_title, style: .default){action in
                aaction()})
            on.present(alertController, animated: true, completion: nil)
        }
    }
    
    public static func ShowActivityIndicator (){
        SVProgressHUD.show()
        UIApplication.shared.beginIgnoringInteractionEvents()
    }
    
    public static func ShowActivityIndicator (withStatus: String){
        SVProgressHUD.show(withStatus: withStatus)
        UIApplication.shared.beginIgnoringInteractionEvents()
    }
    
    public static func DismissActivityIndicator (){
        SVProgressHUD.dismiss()
        UIApplication.shared.endIgnoringInteractionEvents()
    }
    
//    public static func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
//        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
//    }
    
    /*todo: add a finish handlder on it */
//    public static func downloadImage(from url: URL) {
//        print("Download Started")
//        getData(from: url) { data, response, error in
//            guard let data = data, error == nil else { return }
//            print(response?.suggestedFilename ?? url.lastPathComponent)
//            print("Download Finished")
//            DispatchQueue.main.async() {
//                //UI thread do whatever you want after download
//            }
//        }
//    }
}
