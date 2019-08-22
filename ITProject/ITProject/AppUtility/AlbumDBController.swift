//
//  AlbumDBController.swift
//  ITProject
//
//  Created by Gilbert Vincenta on 16/8/19.
//  Copyright © 2019 liquid. All rights reserved.
//

import Foundation

import Firebase


/// <#Description#>
/// functions for  creating albums and adding photos into album.
class AlbumDBController {
    
    private static var single: AlbumDBController!;
    /* constant for ALBUMS collections */
    public static let ALBUM_COLLECTION_NAME = "albums"
    
    public static let ALBUM_DOCUMENT_FIELD_NAME = "name" // album's name
    public static let ALBUM_DOCUMENT_FIELD_DESCRIPTION = "description" // album's description

    public static let ALBUM_DOCUMENT_FIELD_MEDIA = "media_file_paths" // the media files associated
    public static let ALBUM_DOCUMENT_FIELD_FAMILY = "family_path" // the families associated in album
    public static let ALBUM_DOCUMENT_FIELD_OWNER = "owner_path" // the owner associated in album

    
    /* constant for MEDIA collections */
    public static let MEDIA_COLLECTION_NAME = "media"
    public static let MEDIA_DOCUMENT_FIELD_WATCH = "watch" // # of watches
    public static let MEDIA_DOCUMENT_FIELD_LIKES = "likes" // # of likes
    public static let MEDIA_DOCUMENT_FIELD_COMMENTS = "comments" // comments field
    public static let MEDIA_DOCUMENT_FIELD_DESCRIPTION = "description" // description field
    public static let MEDIA_DOCUMENT_FIELD_EXTENSION = "extension" // file extension field


    init (){


    }
    /// <#Description#>
    /// singleton pattern:
    /// - Returns: return an instance of this AlbumDBController.
    public static func getInstance() -> AlbumDBController{
        if (single == nil){
            single = AlbumDBController()
        }
        return single;
    }
    
    
    /// <#Description#>
    /// creates a new album and attaches it to the family.
    /// - Parameters:
    ///   - albumName: name of the album to be added.
    ///   - description: album's short description.
    ///   - completion: gives the album's DocumentReference.
    public func addNewAlbum(albumName : String, description: String,
                            completion: @escaping (DocumentReference?) -> () ) {
        
        //get currentUser's family
        let user = Auth.auth().currentUser!.uid
        let userDocumentReference = DBController.getInstance().getDocumentReference(collectionName: RegisterDBController.USER_COLLECTION_NAME, documentUID: user);
        DBController.getInstance()
            .getDocumentFromCollection(
                collectionName: RegisterDBController.USER_COLLECTION_NAME,
                documentUID:  user)
        {  (document, error) in
            if let document = document, document.exists {
                let familyDocRef:DocumentReference? = document.get(RegisterDBController.USER_DOCUMENT_FIELD_FAMILY) as! DocumentReference?
                
//                let familyDocumentReference:DocumentReference = DBController.getInstance().getDocumentReference(collectionName: RegisterDBController.FAMILY_COLLECTION_NAME, documentUID: familyUID as! String);
                
                        /*init new album */
                //update: album has reference to family + owner/creator.
                
                let albumDocumentReference:DocumentReference? = DBController.getInstance()
                        .addDocumentToCollection(
                        inputData: [
                            AlbumDBController.ALBUM_DOCUMENT_FIELD_NAME : albumName,
                            AlbumDBController.ALBUM_DOCUMENT_FIELD_MEDIA : [],
                            AlbumDBController.ALBUM_DOCUMENT_FIELD_DESCRIPTION : description ,
                            AlbumDBController.ALBUM_DOCUMENT_FIELD_FAMILY : familyDocRef!,
                            AlbumDBController.ALBUM_DOCUMENT_FIELD_OWNER : userDocumentReference],
                        collectionName: AlbumDBController.ALBUM_COLLECTION_NAME);
                
                
                
                        /*add album to family*/
                        DBController.getInstance()
                            .updateArrayField(collectionName: RegisterDBController.FAMILY_COLLECTION_NAME,
                                              documentUID: familyDocRef!.documentID,
                                              fieldName: RegisterDBController.FAMILY_DOCUMENT_FIELD_ALBUM_PATHS, appendValue:albumDocumentReference! );
                
                /*listens to album updates*/
//                self.addAlbumSnapshotListener(familyDocumentReference: familyDocRef!);
                completion(albumDocumentReference);
                
           
                
                
                
            } else {
                print("ERROR at addNewAlbum::: ERROR RETRIEVING DOCUMENT: "+error!.localizedDescription)
            }
        }


        
    }
    
    /// <#Description#>
    /// adds a media file's path into a "media" collection,
    /// and attaches it into an album.
    /// - Parameters:
    ///   - desc: the (short) media file's description
    ///   - ext: the file extension (e.g. .zip)
    ///   - albumUID: the UID of the album to be updated.
    ///   - mediaPath:  the media file's path to be inserted ( unique), preferrably fullPaths.
    public func addPhotoToAlbum(desc : String, ext : String, albumUID : String, mediaPath:String){
        /*init new media */
        DBController
            .getInstance()
            .addDocumentToCollectionWithUID(
                documentUID: mediaPath,
                inputData: [
                    AlbumDBController.MEDIA_DOCUMENT_FIELD_WATCH : 0,
                    AlbumDBController.MEDIA_DOCUMENT_FIELD_LIKES :0,
                    AlbumDBController.MEDIA_DOCUMENT_FIELD_COMMENTS: "",
                    AlbumDBController.MEDIA_DOCUMENT_FIELD_EXTENSION : ext,
                    AlbumDBController.MEDIA_DOCUMENT_FIELD_DESCRIPTION : desc],
                    collectionName: AlbumDBController.MEDIA_COLLECTION_NAME)
        
        /*add path to album*/
         DBController.getInstance()
            .updateArrayField(
                collectionName: AlbumDBController.ALBUM_COLLECTION_NAME,
                documentUID: albumUID,
                fieldName: AlbumDBController.ALBUM_DOCUMENT_FIELD_MEDIA,
                appendValue:mediaPath );
    }
    
    /// <#Description#>
    ///gets all media file paths from an album.
    /// - Parameters:
    ///   - albumUID: album's UID to be retrieved
    ///   - completion: gives all the media file paths  of the album.
    public func getPhotosFromAlbum(albumUID : String, completion: @escaping ([String]) -> ()) {
        
        DBController.getInstance()
            .getDocumentFromCollection(
            collectionName: AlbumDBController.ALBUM_COLLECTION_NAME,
            documentUID: albumUID)
            { (document, error) in
            if let document = document, document.exists {
                //get all media file paths: 
                let mediaFilePaths:[String] = document
                    .get(AlbumDBController.ALBUM_DOCUMENT_FIELD_MEDIA) as! [String]
                print("MediaFilePaths at getPhotosFromAlbum::: \(mediaFilePaths)");
                
                completion(mediaFilePaths);
                
                // download each specified media from storage:
//                for path in mediaFilePaths {
//                    Util.DownloadFileFromServer(fileFullPath: path);
//                }

                
            } else {
                print("ERROR at getPhotosFromAlbum::: ERROR RETRIEVING DOCUMENT: "+error!.localizedDescription)
            }
            
            
            
        }
    }
    
    
    
    
    
    /// <#Description#>
    ///gets all album listeners for certain user's family.
    /// useful for getting notified for updates / deletions / additions to albums.
    /// - Parameter familyDocumentReference: user's family
    public func addAlbumSnapshotListener(familyDocumentReference: DocumentReference){
        
        DBController
            .getInstance()
            .getDB()
            .collection(AlbumDBController.ALBUM_COLLECTION_NAME)
            .whereField(AlbumDBController.ALBUM_DOCUMENT_FIELD_FAMILY,
                        isEqualTo: familyDocumentReference as Any)
            .addSnapshotListener { querySnapshot, error in
                guard let snapshot = querySnapshot else {
                    print("addAlbumSnapshotListener::: Error fetching snapshots: \(error!)")
                    return
                }
                snapshot.documentChanges
                    .forEach { diff in
                    if (diff.type == .added) {
                        print("addAlbumSnapshotListener::: New photos added: \(diff.document.data())")
                    }
                    if (diff.type == .modified) {
                        print(" addAlbumSnapshotListener ::: Modified photos: \(diff.document.data())")
                    }
                    if (diff.type == .removed) {
                        print("addAlbumSnapshotListener::: Removed photos: \(diff.document.data())")
                    }
                }
            }  
        }
    /// <#Description#>
    /// remove a media from album in database (as well as storage).
    /// - Parameters:
    ///   - mediaPath: media's file path to be removed form album.
    ///   - albumUID: the albumUID that the media belongs to.
    public func deleteMediaFromAlbum(mediaPath : String, albumUID: String ){
        //from firestore::
        
        //remove reference from album:
        DBController.getInstance()
            .removeArrayField(
                collectionName: AlbumDBController.ALBUM_COLLECTION_NAME,
                documentUID: albumUID,
                fieldName: AlbumDBController.ALBUM_DOCUMENT_FIELD_MEDIA,
                removeValue: mediaPath);
        
        //delete media document from media collection:
        DBController.getInstance()
            .deleteWholeDocumentfromCollection(
                documentUID: mediaPath,
                collectionName: AlbumDBController.MEDIA_COLLECTION_NAME);
        
        
        //from storage::
        //TODO: remove photo file from storage:
        
        
        
    }
    /// <#Description#>
    ///
    /// - Parameters:
    ///   - albumUID: album's UID to be deleted.

    public func deleteAlbum(albumUID: String){//, mediaPath:String ){
        
        //from storage: TODO: remove all photo files (related to the album) from storage:
        
        
        //(from firestore) remove all images document:
//         DBController.getInstance()
//            .deleteWholeDocumentfromCollection(
//                documentUID: mediaPath,
//                collectionName: AlbumDBController.MEDIA_COLLECTION_NAME);
        
        //(from firestore) remove album document:
         DBController.getInstance()
            .deleteWholeDocumentfromCollection(
                documentUID: albumUID,
                collectionName: AlbumDBController.ALBUM_COLLECTION_NAME);
        
        
        
    }
}

