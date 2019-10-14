//
//  Util.swift
//  ITProject
//
//  Created by Gong Lehan on 9/8/19.
//  Copyright © 2019 liquid. All rights reserved.
//

import Firebase
import FirebaseStorage
import Foundation
import Photos
import SVProgressHUD
import Zip

struct ActionSheetDetail{
    let title:String!
    let style:UIAlertAction.Style!
    let action:((UIAlertAction) -> Void)?
}

/// <#Description#>
/// This is file which share the common constants or functions to the whole project

class Util {
    // Constants and properties go here
    public static let BUTTON_DISMISS = "dismiss"
    public static let EXTENSION_JPEG = "jpg"
    public static let EXTENSION_M4A = "m4a"
    public static let EXTENSION_MP4 = "mp4"
    public static let EXTENSION_M4V = "m4v"
    public static let EXTENSION_MOV = "MOV"
    public static let EXTENSION_PNG = "png"
    public static let EXTENSION_ZIP = "zip"
    public static let IMAGE_FOLDER = "images"
    public static let VIDEO_FOLDER = "videos"
    public static let AUDIO_FOLDER = "audios"
    public static let TMP_FOLDER = "tmp"
    public static let FIREBASE_STORAGE_URL = "gs://liquid-248305.appspot.com/"
    public static func GenerateUDID() -> String! {
        let uuid = UUID().uuidString
        return uuid
    }

    public static func PrepareDocumentFolder() {
        DispatchQueue(label: "working_queue", qos: .userInitiated).async {
            CreateImageFolder()
            CreateAudioFolder()
            CreateVideoFolder()
            CreateTmpFolder()
        }
    }

    /// <#Description#>
    /// data : the file date you want to store in the server
    /// metadata : metadata to record your file, usually nil
    /// fileName : the file name of your data with no extension
    /// e.g. 544D51AC-9608-46BD-AE6E-B325F2FC3654
    /// fextension : file extension
    /// e.g. .jpg
    /// completion Handlder : do whatever you want when completed, 1 args : download url to the file in the cloud
    /// errorHandler : handle when error pop up, 1 args : error that occur
    ///
    /// - Returns: return
    public static func UploadFileToServer(data: Data,
                                          metadata: StorageMetadata?,
                                          fileName: String,
                                          fextension: String,
                                          completion: @escaping (URL?) -> Void = { _ in },
                                          errorHandler: @escaping (Error?) -> Void = { _ in }) {
        UploadFileToServer(data: data,
                           metadata: metadata,
                           fileFullName: fileName + "." + fextension,
                           completion: completion,
                           errorHandler: errorHandler)
    }
    
    public static func UploadZipFileToServer(data: Data,
    metadata: StorageMetadata?,
    fileName: String,
    fextension: String,
    completion: @escaping (URL?) -> Void = { _ in },
    errorHandler: @escaping (Error?) -> Void = { _ in }){
        
        let storageRef = Storage.storage().reference()
        
        let folderPath = GetFolderByExtension(fextension: fextension, withPathSlash: true)
        let filePath = folderPath! + fileName + "." + Util.EXTENSION_ZIP
        
        ReadFileFromDocumentDirectory(fileName: filePath) { fileData in

            let sRef = storageRef.child(filePath)

            // Upload the file to the path "images/rivers.jpg"
            _ = sRef.putData(fileData, metadata: metadata) { metadata, error in
                
                print("UploadZipFileToServer : PUT DATA FILEPATH",filePath)
                guard let metadata = metadata else {
                    // Uh-oh, an error occurred!
                    print("UploadZipFileToServer : metadata error : "
                        + error!.localizedDescription)
                    errorHandler(error)
                    return
                }
                print("PUT DATA FILEPATH HAS END",filePath)
                // Metadata contains file metadata such as size, content-type.
                _ = metadata.size
                // You can also access to download URL after upload.
                sRef.downloadURL { url, error in
                    print("downloadURL DATA ANYTHING",filePath)

                    guard url != nil else {
                        // Uh-oh, an error occurred!
                        errorHandler(error)
                        print("UploadZipFileToServer : url error : "
                            + error!.localizedDescription)
                        return
                    }
                    
                    print("URL IS: GOING TO COMPLETION", url)
                    completion(url)
                }
            }
        }
        
    }

    /// <#Description#>
    /// data : the file date you want to store in the server
    /// metadata : metadata to record your file, usually nil
    /// fileFullName : the file name of your data with extension
    /// e.g. 544D51AC-9608-46BD-AE6E-B325F2FC3654.jpg
    /// completion Handlder : do whatever you want when completed, 1 args : download url to the file in the cloud
    /// errorHandler : handle when error pop up, 1 args : error that occur
    ///
    /// - Returns: return value
    public static func UploadFileToServer(data: Data,
                                          metadata: StorageMetadata?,
                                          fileFullName: String,
                                          completion: @escaping (URL?) -> Void = { _ in },
                                          errorHandler: @escaping (Error?) -> Void = { _ in }) {
        let storageRef = Storage.storage().reference()
        let fileFullPath = GetFullFilePath(fileName: fileFullName)
        WriteFileToDocumentDirectory(data: data, fileFullName: fileFullPath) {
            fileUrl in
            let fileNameWithExtension = fileUrl.lastPathComponent as NSString
            let folderPath = fileUrl.deletingLastPathComponent()
            let fileName = fileNameWithExtension.deletingPathExtension
            let fExtension = "." + fileNameWithExtension.pathExtension

            ZipFile(from: folderPath.absoluteString as NSString,
                    to: folderPath.absoluteString as NSString,
                    fileName: fileName, fextension: fExtension, deleteAfterFinish: true) { zipFileUrl in
                let zipFile = zipFileUrl?.lastPathComponent
                let fileFolder = zipFileUrl?.deletingLastPathComponent().lastPathComponent
                let filePath = fileFolder! + "/" + zipFile!

                print("UploadFileToServer : file upload to server : " + filePath)

                ReadFileFromDocumentDirectory(fileName: filePath) { fileData in

                    let sRef = storageRef.child(filePath)

                    // Upload the file to the path "images/rivers.jpg"
                    _ = sRef.putData(fileData, metadata: metadata) { metadata, error in
                        
                        print("PUT DATA FILEPATH",filePath)
                        guard let metadata = metadata else {
                            // Uh-oh, an error occurred!
                            print("UploadFileToServer : metadata error : "
                                + error!.localizedDescription)
                            errorHandler(error)
                            return
                        }
                        print("PUT DATA FILEPATH HAS END",filePath)
                        // Metadata contains file metadata such as size, content-type.
                        _ = metadata.size
                        // You can also access to download URL after upload.
                        sRef.downloadURL { url, error in
                            print("downloadURL DATA ANYTHING",filePath)

                            guard url != nil else {
                                // Uh-oh, an error occurred!
                                errorHandler(error)
                                print("UploadFileToServer : url error : "
                                    + error!.localizedDescription)
                                return
                            }
                            
                            print("URL IS: GOING TO COMPLETION", url)
                            completion(url)
                        }
                    }
                }
            }
        }
    }

    /// <#Description#>
    // Get the image data
    ///
    /// - Returns: <#return value description#>
    public static func GetImageData(imageUID: String?,
                                    UIDExtension: String?,
                                    completion: @escaping (Data?) -> Void = { _ in },
                                    errorHandler: @escaping (Error?) -> Void = { _ in }) {
        
            if let imageid = imageUID, let imageExt = UIDExtension {
                if imageid == ImageAsset.default_image.rawValue {
                    let uiImage =  ImageAsset.default_image.image
                        completion(uiImage.jpegData(compressionQuality: 1.0))
                } else {
                    if let dataCahe = CacheHandler.getInstance().getCache(forKey: imageid) {
                        print("GetImageData : data in cache, fetching... ")
                            completion(dataCahe)
                    } else if GetDataFromLocalFile(filename: imageid, fextension: imageExt, completion: completion) {
                        print("GetImageData : getting image from local documentPath...")
                    } else {
                        print("GetImageData : Local folder doesn't have file, searching from sever..")
                        GetImageFromServer(imageUID: imageid, completion: completion, errorHandler: errorHandler)
                    }
                }
            } else {
                    completion(nil)
                
                print("GetImageData fails: empty Image URL")
            }
    }
    enum FileType {
        case video
        case audio
    }
    
    public static func GetLocalFileURL(by UID: String, type fileType: FileType,  error: @escaping (Error?) -> Void = { _ in },  completion: @escaping (URL?) -> Void = { _ in }){
        // looking for oringinal file from video folder first
        let m4vPath = GetLocalFileFullPath(filename: UID, fextension: Util.EXTENSION_M4V)!
        print("GetLocalFileURL : the m4v path : " + m4vPath)
        let mp4Path = GetLocalFileFullPath(filename: UID, fextension: Util.EXTENSION_MP4)!
        print("GetLocalFileURL : the mp4 path : " + mp4Path)
        let m4aPath = GetLocalFileFullPath(filename: UID, fextension: Util.EXTENSION_M4A)!
        print("GetLocalFileURL : the m4a path : " + m4aPath)
        
        
        
        switch fileType {
        case .video:
            
            let pathWithNoExtension = URL(string: m4vPath)?.deletingPathExtension()
            let zipPath = pathWithNoExtension?.appendingPathExtension(Util.EXTENSION_ZIP)
            print("GetLocalFileURL : the video zip path : " + zipPath!.absoluteString)
            
            if DoesFileExist(fullPath: m4vPath){
                // m4v found, completion
                print("m4v found, completion")
                completion(URL(string: m4vPath))
            }else if DoesFileExist(fullPath: mp4Path){
                // mp4 found, completion
                 print("mp4 found, completion")
                completion(URL(string: mp4Path))
            }else if DoesFileExist(fullPath: zipPath!.absoluteString) {
                // unzip file and then give url
                let folderPath = pathWithNoExtension?.deletingLastPathComponent().absoluteString
                 print("GetLocalFileURL : the video folderPath : " + folderPath!)
                
                let zipfilePath =
                    pathWithNoExtension?.lastPathComponent
                print("GetLocalFileURL : the video zipFile : " + zipfilePath!)
                
                Util.UnzipFile(from: folderPath! as NSString, to: folderPath! as NSString, fileName: zipfilePath! + "." + Util.EXTENSION_ZIP, deleteAfterFinish: true){
                    url in
                    completion(url)
                }
            }else{ // not in local, try fecth from sever
                print("else case, completion")

                let fileFullPath = VIDEO_FOLDER + "/" + zipPath!.lastPathComponent
                Util.DownloadFileFromServer(fileFullPath: fileFullPath, completion: {
                    url in
                    
                    completion(url)
                }, errorHandler: {
                    e in
                    error(e)
                })
            }
        case .audio:
            
            let pathWithNoExtension = URL(string: m4aPath)?.deletingPathExtension()
            let zipPath = pathWithNoExtension?.appendingPathExtension(Util.EXTENSION_ZIP)
            print("GetLocalFileURL : the audio zip path : " + zipPath!.absoluteString)
            
            if DoesFileExist(fullPath: m4aPath){
               // m4v found, completion
               completion(URL(string: m4aPath))
            }else if DoesFileExist(fullPath: zipPath!.absoluteString) {
               // unzip file and then give url
               let folderPath = pathWithNoExtension?.deletingLastPathComponent().absoluteString
                print("GetLocalFileURL : the audio folderPath : " + folderPath!)
               
               let zipfilePath =
                   pathWithNoExtension?.lastPathComponent
               print("GetLocalFileURL : the audio folderPath : " + zipfilePath!)
               
               Util.UnzipFile(from: folderPath! as NSString, to: folderPath! as NSString, fileName: zipfilePath! + "." + Util.EXTENSION_ZIP, deleteAfterFinish: true){
                   url in
                   completion(url)
               }
            }else {
                
                let fileFullPath = AUDIO_FOLDER + "/" + zipPath!.lastPathComponent
                Util.DownloadFileFromServer(fileFullPath: fileFullPath, completion: {
                    url in
                    
                    completion(url)
                }, errorHandler: {
                    e in
                    error(e)
                })
            }
        }
    }

    /// <#Description#>
    /// Get the image from server
    /// short cut to get Image from server by UID
    /// imageUID : UID of the image
    /// completion : do whatever you want to do when completion data : the image data
    /// errorHandler : do whatever you want to do when error occur
    ///
    /// - Returns: return value
    public static func GetImageFromServer(imageUID: String,
                                          completion: @escaping (Data?) -> Void = { _ in },
                                          errorHandler: @escaping (Error?) -> Void = { _ in }) {
        let fullFliePath = Util.GetImagePathByUID(imageUID: imageUID)
        DownloadFileFromServer(fileFullPath: fullFliePath, completion: { url in

            let fileLastPathUrl = (url?.lastPathComponent)! as NSString
            let filenameWithNoExtension = fileLastPathUrl.deletingPathExtension
            let fileExtension = fileLastPathUrl.pathExtension

            print("Get Image from serever, Full url file : " + (fileLastPathUrl as String))
            print("Get Image from serever , filenameWithNoExtension :" + filenameWithNoExtension)
            print("Get Image from serever , fileExtension :" + fileExtension)

            _ = Util.GetDataFromLocalFile(filename: filenameWithNoExtension, fextension: fileExtension, completion: { data in
                completion(data)
            })

        }, errorHandler: errorHandler)
    }

    /// <#Description#>
    /// Get the image path
    ///
    /// - Parameter imageUID: image id
    /// - Returns: return value
    public static func GetImagePathByUID(imageUID: String) -> String {
        return Util.IMAGE_FOLDER + "/" + imageUID + "." + Util.EXTENSION_ZIP
    }

    /// <#Description#>
    /// Download file from server and unzip the image
    ///
    /// - Returns: return value
    public static func DownloadFileFromServer(fileFullPath: String,
                                              completion: @escaping (URL?) -> Void = { _ in },
                                              errorHandler: @escaping (Error?) -> Void = { _ in }) {
        print("DownloadFileFromServer :file path " + fileFullPath)

        let gsReference = Storage.storage().reference(forURL: FIREBASE_STORAGE_URL + fileFullPath)

        let localURL = URL(fileURLWithPath: GetDocumentsDirectory().appendingPathComponent(fileFullPath).absoluteString)
        print("DownloadFileFromServer to : " + localURL.absoluteString)
        // Download to the local filesystem
        _ = gsReference.write(toFile: localURL) { url, error in
            if let error = error {
                // Uh-oh, an error occurred!
                print("DownloadFileFromServer fail")
                print(error)
                errorHandler(error)
            } else {
                // Local file URL for "images/island.jpg" is returned
                print("DownloadFileFromServer success with url :")
                print(url!)

//                print(Thread.current) // this is a UI thread

                let fileAt = url!.deletingLastPathComponent().absoluteString
                print("DownloadFileFromServer local fileAt :" + fileAt)
                let fileName = ((url!.lastPathComponent) as NSString)
                print("DownloadFileFromServer  fileName :" + (fileName as String))

                UnzipFile(from: fileAt as NSString,
                          to: fileAt as NSString,
                          fileName: fileName as String,
                          deleteAfterFinish: false) {
                    filepath in
                    completion(filepath)
                }
            }
        }
    }

    /// <#Description#>
    /// Delete the selected file from server
    ///
    /// - Parameters:
    ///   - fileName: file name
    ///   - fextension: fextension description
    public static func DeleteFileFromServer(fileName: String, fextension: String) {
        let fileFullPath = GetFolderByExtension(fextension: fextension, withPathSlash: true)! + fileName + "." + Util.EXTENSION_ZIP
        let desertRef = Storage.storage().reference(forURL: FIREBASE_STORAGE_URL + fileFullPath)

        // Delete the file
        desertRef.delete { error in
            if let error = error {
                // Uh-oh, an error occurred!
                print("DeleteFileFromServer : " + error.localizedDescription)
            } else {
                // File deleted successfully
                print("DeleteFileFromServer : delete successful for file : " + fileFullPath)
            }
        }
    }

    /// <#Description#>
    /// Zipfile function :
    ///
    /// from : zipfile location (folderPath)
    /// to : destination (folderPath)
    /// filename : the file need to be ziped, with no extension
    /// fextension : the file extension
    /// deleteAfterFinish : delete the original file after finished zipping
    /// completion handler : what you want to do after unzip, argument url : fullPath to the destination with filename. e.g.  /Users/xxxxxxxxxxxx/Documents/images/2E61DCE8-B133-4936-BDC7-E90FB4199B21.zip
    ///
    /// - Returns: return value
    public static func ZipFile(from: NSString, to: NSString,
                               fileName: String, fextension: String,
                               deleteAfterFinish: Bool,
                               completion: @escaping (URL?) -> Void = { _ in }) {
        DispatchQueue(label: "working_queue", qos: .userInitiated).async {
            let fullFilePath = from.appendingPathComponent(fileName + fextension)
            let fullDestinationPath = to.appendingPathComponent(fileName + "." + Util.EXTENSION_ZIP)
            print("ZipFile : fullFilePath : " + fullFilePath)
            print("ZipFile : fullDestinationPath : " + fullDestinationPath)
            do {
                try Zip.zipFiles(paths: [URL(string: fullFilePath)!], zipFilePath: URL(string: fullDestinationPath)!, password: nil, progress: { (progress) -> Void in
                    print("ZipFile : progress" + String(progress))
                })

                if deleteAfterFinish {
                    try FileManager.default.removeItem(at: URL(string: fullFilePath)!)
                }
                completion(URL(string: fullDestinationPath))
            } catch let error as NSError {
                print("ZipFile : error occurs during zip ," + error.localizedDescription)
            }
        }
    }

    public static func GetExtensionByFolderPath(fileFullPath: String) -> String? {
        if fileFullPath.contains(Util.IMAGE_FOLDER + "/") {
            return Util.EXTENSION_JPEG
        }else if fileFullPath.contains(Util.VIDEO_FOLDER + "/") {
            return Util.EXTENSION_M4V
        }else if fileFullPath.contains(Util.AUDIO_FOLDER + "/") {
            return Util.EXTENSION_M4A
        }
        return nil
    }

    /// <#Description#>
    /// Unzipfile function :
    /// from : unzipfile location (folderPath)
    /// to : destination (folderPath)
    /// filename : the file need to be unzip, with extension .zip
    /// deleteAfterFinish : delete the zip file after finished unzipping
    /// completion handler : what you want to do after unzip, argument url : fullPath to the destination with filename. e.g.  file:/Users/xxxxxxxxxxxx/Documents/images/2E61DCE8-B133-4936-BDC7-E90FB4199B21.jpg */
    ///
    /// - Returns: return value
    public static func UnzipFile(from: NSString, to: NSString,
                                 fileName: String, deleteAfterFinish: Bool,
                                 completion: @escaping ((URL) -> Void) = { _ in }) {
        let fullFilePath = from.appendingPathComponent(fileName)
        var unzippedFile = (fileName as NSString).deletingPathExtension
        unzippedFile = (unzippedFile as NSString).appendingPathExtension(GetExtensionByFolderPath(fileFullPath: to as String)!)!

        var unzippedOutputFile: URL?

        DispatchQueue(label: "working_queue", qos: .userInitiated).async {
            do {
                try Zip.unzipFile(URL(string: fullFilePath)!, destination: URL(string: to as String)!, overwrite: true, password: nil, progress: { (progress) -> Void in
                    print("UnzipFile : progress " + String(progress))
                    if progress >= 1.0 {
                        let unzipped = unzippedOutputFile ?? URL(string: to.appendingPathComponent(unzippedFile))

                        completion(unzipped!)
                        if deleteAfterFinish {
                            do {
                                try FileManager.default.removeItem(at: URL(fileURLWithPath: fullFilePath))
                                print("DELETE AFTER FINISH SUCEED" )

                            } catch let error as NSError {
                                print("UnzipFile : error occurs during remove unzip : " + error.localizedDescription)
                            }
                        }
                    }
                }, fileOutputHandler: {
                    fileUrl in

                    if !fileUrl.absoluteString.contains("/__MACOSX") {
                        unzippedOutputFile = fileUrl
                        print("unzipped file full url : " + fileUrl.absoluteString)
                    }
                })
            } catch let error as NSError {
                print("UnzipFile : error occurs during unzip : " + error.localizedDescription)
            }
        }
    }

    /// <#Description#>
    /// note : read write file opearation, use worker thread to do it*/
    ///
    /// Read file from document directory
    /// fileFullname : fileFullname with extension including extension folder path
    /// e.g. images/544D51AC-9608-46BD-AE6E-B325F2FC3654.zip
    /// completion Handlder : do stuffs when completed,
    /// 1 args data that you have read from the file
    ///
    /// - Returns: return value
    public static func ReadFileFromDocumentDirectory(fileName: String,
                                                     completion: @escaping (Data) -> Void = { _ in }) {
        DispatchQueue(label: "working_queue", qos: .userInitiated).async {
            let fileFullPath = GetDocumentsDirectory().appendingPathComponent(fileName).absoluteString
            print("ReadFileFromDocumentDirectory : full file path : " + fileFullPath)
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: fileFullPath))
                completion(data)
                print("ReadFileFromDocumentDirectory : success")
            } catch let error as NSError {
                print("ReadFileFromDocumentDirectory : " + error.localizedDescription)
            }
        }
    }

    /// <#Description#>
    /// note : read write file opearation, use worker thread to do it
    /// Write file to document directory
    /// data : the data that write to the file
    /// fileFullname : fileFullname including extension folder path
    /// e.g. images/544D51AC-9608-46BD-AE6E-B325F2FC3654.jpg
    /// completion Handlder : do stuffs when completed,
    /// 1 args full filePath to written file.
    /// e.g. file:///Users/xxxx/Documents/images/544D51AC-9608-46BD-AE6E-B325F2FC3654.jpg
    ///
    /// - Returns: <#return value description#>
    public static func WriteFileToDocumentDirectory(data: Data,
                                                    fileFullName: String,
                                                    completion: @escaping (URL) -> Void = { _ in }) {
        DispatchQueue(label: "working_queue", qos: .userInitiated).async {
            let fileWriteTo = URL(fileURLWithPath: GetDocumentsDirectory().appendingPathComponent(fileFullName).absoluteString)
            print("WriteFileToDocumentDirectory : full file path : " + fileWriteTo.absoluteString)
            do {
                try data.write(to: fileWriteTo)
                completion(fileWriteTo)
                print("WriteFileToDocumentDirectory : success")
            } catch let error as NSError {
                print("WriteFileToDocumentDirectory : " + error.localizedDescription)
            }
        }
    }
    
    public static func GetLocalFileFullPath(filename: String, fextension: String)->String!{
        let folderPath = GetFolderByExtension(fextension: fextension, withPathSlash: true)!
        let fileDocumentFullPath = GetDocumentsDirectory().appendingPathComponent(folderPath, isDirectory: true).absoluteString as NSString
        let filenameWithExtension = URL(string: filename)?.appendingPathExtension(fextension).absoluteString

        let fileFullPath = fileDocumentFullPath.appendingPathComponent(filenameWithExtension!)
        
        return fileFullPath
    }

    /// <#Description#>
    /// usually is a zip file, so we need to unzip
    /// , NOTE : completion is in main thread, as it's usually a UI task.
    /// switch to background thread outside if you need it.
    /// filename : fileName with no extension
    /// e.g. "544D51AC-9608-46BD-AE6E-B325F2FC3654"
    /// fextension : file extension e.g. ".jpg"
    /// completion Handler : do what you want with the file data with it, 1 args data
    ///
    /// - Returns: <#return value description#>
    public static func GetDataFromLocalFile(filename: String, fextension: String, completion: @escaping (Data) -> Void = { _ in }) -> Bool {
        print("GetDataFromLocalFile : filename : " + filename)
        print("GetDataFromLocalFile : fileExtension : " + fextension)

        let folderPath = GetFolderByExtension(fextension: fextension, withPathSlash: true)!
        let fileDocumentFullPath = GetDocumentsDirectory().appendingPathComponent(folderPath, isDirectory: true).absoluteString as NSString
        let filenameWithExtension = URL(string: filename)?.appendingPathExtension(fextension).absoluteString

        let fileFullPath = fileDocumentFullPath.appendingPathComponent(filenameWithExtension!)
        print("GetDataFromFile :looking in oringinal file : " + fileFullPath)

        // if file simply exists, just read and open it.
        if DoesFileExist(fullPath: fileFullPath) {
            print("GetDataFromFile : oringinal file exist, no need for unzip :" +
                fileFullPath)
            ReadFileFromDocumentDirectory(fileName: GetFullFilePath(fileName: filenameWithExtension!)) {
                data in
                print("GetDataFromFile : get file data success")
                // added cache here
                CacheHandler.getInstance()
                    .setCache(obj: data, forKey: filename)
                DispatchQueue.main.async {
                    completion(data)
                }
            }
            return true
        } else { // if not, find a zip file, unzip and then get data
            let zipFilename = URL(string: filename)?.appendingPathExtension(EXTENSION_ZIP).absoluteString
            let zipFileFullPath = fileDocumentFullPath.appendingPathComponent(zipFilename!)
            print("GetDataFromFile : going to unzip :" + zipFileFullPath)

            if DoesFileExist(fullPath: zipFileFullPath) {
                UnzipFile(from: fileDocumentFullPath, to: fileDocumentFullPath, fileName: zipFilename!, deleteAfterFinish: false) { url in

                    print("GetDataFromFile : unzip  with file url :" + url.absoluteString)
                    ReadFileFromDocumentDirectory(fileName: GetFullFilePath(fileName: url.lastPathComponent)) {
                        data in
                        print("GetDataFromFile : get file data success")
                        DispatchQueue.main.async {
                            completion(data)
                        }
                    }
                }
                return true
            } else {
                print("zip file doesn't exist, retrive file fail")
                return false
            }
        }
    }

    public static func GetFolderForFile(fileName: NSString) -> String? {
        return GetFolderForFile(fileName: fileName, withPathSlash: true)
    }

    public static func GetFolderForFile(fileName: NSString, withPathSlash: Bool) -> String? {
        return GetFolderByExtension(fextension: "." + fileName.pathExtension,
                                    withPathSlash: withPathSlash)
    }

    /// find correspond folder for the extension
    /// fextension: file extension e.g. ".jpg"
    /// withPathSlash: add pathSlash "/" at the end of the folder
    /// - Parameters:
    ///   - fextension: fextension
    ///   - withPathSlash: withPathSlash
    /// - Returns: return value
    public static func GetFolderByExtension(fextension: String, withPathSlash: Bool) -> String? {
        if fextension == EXTENSION_JPEG ||
            fextension == ("." + EXTENSION_JPEG) ||
            fextension == EXTENSION_PNG ||
            fextension == ("." + EXTENSION_PNG) {
            
            return withPathSlash ? (IMAGE_FOLDER + "/") : IMAGE_FOLDER
        }else if fextension == EXTENSION_MP4 ||
            fextension == ("." + EXTENSION_MP4) ||
            fextension == EXTENSION_M4V ||
            fextension == ("." + EXTENSION_M4V) ||
            fextension == EXTENSION_MOV ||
            fextension == ("." + EXTENSION_MOV) {
            
            return withPathSlash ? (VIDEO_FOLDER + "/") : VIDEO_FOLDER
        }else if fextension == EXTENSION_M4A ||
            fextension == ("." + EXTENSION_M4A) {
            
            return withPathSlash ? (AUDIO_FOLDER + "/") : AUDIO_FOLDER
        }
        
        return nil
    }

    public static func GetDocumentFullFilePath(fileName: String) -> String {
        return GetDocumentsDirectory().appendingPathComponent(GetFolderForFile(fileName: fileName as NSString)! + fileName).absoluteString
    }

    /// get file full path according to the file extension
    /// fileName : file name with extension
    /// e.g. 544D51AC-9608-46BD-AE6E-B325F2FC3654.zip
    /// return : fileFolder/filename
    /// e.g. images/544D51AC-9608-46BD-AE6E-B325F2FC3654.zip
    /// - Parameter fileName: file name
    /// - Returns: return the string the the file folder
    public static func GetFullFilePath(fileName: String) -> String {
        return GetFolderForFile(fileName: fileName as NSString)! + fileName
    }

    /// DocumentDirectory for the app that allows us to do read and write
    /// - Returns: return the document directory
    public static func GetDocumentsDirectory() -> URL {
        return URL(string: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])!
    }

    public static func GetImageDirectory() -> URL {
        return GetDocumentsDirectory().appendingPathComponent(IMAGE_FOLDER, isDirectory: true)
    }
    
    public static func GetVideoDirectory() -> URL {
        return GetDocumentsDirectory().appendingPathComponent(VIDEO_FOLDER, isDirectory: true)
    }
    
    public static func GetAudioDirectory() -> URL {
        return GetDocumentsDirectory().appendingPathComponent(AUDIO_FOLDER, isDirectory: true)
    }

    public static func GetTmpDirectory() -> URL {
        return GetDocumentsDirectory().appendingPathComponent(TMP_FOLDER, isDirectory: true)
    }

    /// Create folders in the documents
    /// - Parameter folderURL: folder URL
    public static func CreateFolderInDocuments(folderURL: URL) {
        var isDir: ObjCBool = true

        if !FileManager.default.fileExists(atPath: folderURL.absoluteString, isDirectory: &isDir) {
            do {
                try FileManager.default.createDirectory(atPath: folderURL.absoluteString, withIntermediateDirectories: true, attributes: nil)
                print("CreateFolderInDocuments: Created " + folderURL.absoluteString + " success : "
                    + String(DoesDirectoryExist(fullPath: folderURL.absoluteString)))
            } catch {
                print("CreateFolderInDocuments: Creating " + folderURL.absoluteString + " " + error.localizedDescription)
            }
        } else {
            print("CreateFolderInDocuments: " + folderURL.absoluteString + " already exist, don't need to create ")
        }
    }

    /// Create the image folder for later use
    public static func CreateImageFolder() {
        let dataPath = GetDocumentsDirectory().appendingPathComponent(IMAGE_FOLDER, isDirectory: true)
        CreateFolderInDocuments(folderURL: dataPath)
    }
    
    /// Create the Video folder for later use
    public static func CreateVideoFolder() {
        let dataPath = GetDocumentsDirectory().appendingPathComponent(VIDEO_FOLDER, isDirectory: true)
        CreateFolderInDocuments(folderURL: dataPath)
    }
    
    /// Create the Audio folder for later use
    public static func CreateAudioFolder() {
        let dataPath = GetDocumentsDirectory().appendingPathComponent(AUDIO_FOLDER, isDirectory: true)
        CreateFolderInDocuments(folderURL: dataPath)
    }

    /// Create the tmp folder for later use
    public static func CreateTmpFolder() {
        let dataPath = GetDocumentsDirectory().appendingPathComponent(TMP_FOLDER, isDirectory: true)
        CreateFolderInDocuments(folderURL: dataPath)
    }

    /// Check if the file exist
    /// - Parameter fullPath: the path u want to check
    /// - Returns: true for exist
    public static func DoesFileExist(fullPath: String) -> Bool {
        return DoesFileExist(fullPath: fullPath, checkIsDirectory: false)
    }

    /// Check if the directory exist
    /// - Parameter fullPath: the path u want to check
    /// - Returns: true for exist
    public static func DoesDirectoryExist(fullPath: String) -> Bool {
        return DoesFileExist(fullPath: fullPath, checkIsDirectory: true)
    }

    /// Check if the file exist
    /// - Parameters:
    ///   - fullPath: the path u want to check
    ///   - checkIsDirectory: check if it is a directory
    /// - Returns: true for exist
    public static func DoesFileExist(fullPath: String, checkIsDirectory: Bool) -> Bool {
        let fileManager = FileManager.default
        var isDir: ObjCBool = false
        if fileManager.fileExists(atPath: fullPath, isDirectory: &isDir) {
            if isDir.boolValue {
                print("DoesFileExist: file exists and is a directory")
                if checkIsDirectory {
                    return true
                } else {
                    return false
                }
            } else {
                print("DoesFileExist: file exists and is not a directory")
                if checkIsDirectory {
                    return false
                } else {
                    return true
                }
            }
        } else {
            print("DoesFileExist: file does not exist")
            return false
        }
    }

    public static func UserInitThread(work: @escaping (() -> Void) = {}) {
        DispatchQueue(label: "working_queue", qos: .userInitiated).async {
            work()
        }
    }

    /// Based on the string given, pop alert to the user
    /// - Returns: return value description
    public static func ShowAlert(title: String,
                                 message: String,
                                 action_title: String,
                                 on: UIViewController,
                                 aaction: @escaping (() -> Void) = {}) {
        /* present alert always on UI/main thread */
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: action_title, style: .default) { _ in
                aaction()
            })
            on.present(alertController, animated: true, completion: nil)
        }
    }

    /// Shows loading indicator.
    public static func ShowActivityIndicator() {
        DispatchQueue.main.async {
            SVProgressHUD.show()
            // UI thread do whatever you want after download
            UIApplication.shared.beginIgnoringInteractionEvents()
        }
    }

    /// Shows loading indicator.
    /// - Parameter withStatus: the message to be sent to user.
    public static func ShowActivityIndicator(withStatus: String) {
        DispatchQueue.main.async {
            SVProgressHUD.show(withStatus: withStatus)
            UIApplication.shared.beginIgnoringInteractionEvents()
        }
    }

    /// Closes loading indicator.
    public static func DismissActivityIndicator() {
        DispatchQueue.main.async {
            SVProgressHUD.dismiss()
            UIApplication.shared.endIgnoringInteractionEvents()
        }
    }

    /// Change user's displayed names
    /// - Parameter user: the user to  be changed.
    /// - Parameter username: the new username.
    /// - Parameter completion: passes on error signs.
    public static func ChangeUserDisplayName(user: User, username: String, completion: @escaping (Error?) -> Void = { _ in }) {
        let changeRequest = user.createProfileChangeRequest()
        changeRequest.displayName = username
        changeRequest.commitChanges(completion: {
            error in
            if let e = error {
                print("ChangeUserDisplayName :add name in auth error : " + e.localizedDescription)
            }

            completion(error)
        })
    }

    /// Change users' photo url DEPRECATED
    /// - Parameters:
    ///   - imagePath: the image path u want to change
    ///   - ext: ext
    public static func ChangeUserPhotoURL(imagePath: String, ext: String) {
//        let request = Auth.auth().currentUser?.createProfileChangeRequest()
//        request?.photoURL = URL(string: imagePath + "." + ext)
//        request?.commitChanges(completion: { error in
//            if let error = error {
//                print("error in ChangePhotoURL ::: ", error)
//            }
//        })
        //upload to DB:
 
        
    }

    /// There are differernt level of priority
    /// Check if the photo can be acessed by this user
    public static func CheckPhotoAcessPermission() {
        let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        switch photoAuthorizationStatus {
        case .authorized:
            print("checkPermission: Access is granted by user")
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization {
                newStatus in
                print("checkPermission: status is \(newStatus)")
                if newStatus == PHAuthorizationStatus.authorized {
                    /* do stuff here */
                    print("checkPermission: success")
                }
            }
            print("checkPermission: It is not determined until now")
        case .restricted:
            // same same
            print("checkPermission: User do not have access to photo album.")
        case .denied:
            // same same
            print("checkPermission: User has denied the permission.")
        @unknown default:
            print("checkPermission: fatal error.")
        }
    }
    
    public static func ShowBottomAlertView(on view: UIViewController, with buttons: [ActionSheetDetail], completion: (() -> Void)? = nil){
        // Create you actionsheet - preferredStyle: .actionSheet
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        buttons.forEach({
            button in
            
            let action = UIAlertAction(title: button.title, style: button.style) { (action) in
                if let actionFunction = button.action {
                    actionFunction(action)
                }
            }
                
            actionSheet.addAction(action)
        })

        // Present the controller
        view.present(actionSheet, animated: true, completion: nil)
    }

    public static func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }

    /// Download the image from the given url
    /// - Parameter url: url to be downloaded from
    /// - Parameter completion: passes on the data and response from downloaded URL.
    public static func downloadImage(from url: URL,
                                     completion: @escaping (Data?, URLResponse?, Error?) -> Void = { _, _, _ in }) {
        print("Download Started")
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            print("Download Finished")
            DispatchQueue.main.async {
                // UI thread do whatever you want after download
                completion(data, response, error)
            }
        }
    }
    
    public static func secondsToMinutesSeconds(seconds : Int) -> (Int, Int) {

        return (seconds / 3600, (seconds / 60) % 60)
    }
}
