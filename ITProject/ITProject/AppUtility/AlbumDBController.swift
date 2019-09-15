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
    
    public static let ALBUM_DOCUMENT_FIELD_MEDIAS = "media_file_paths" // the media files associated
    public static let ALBUM_DOCUMENT_FIELD_FAMILY = "family_path" // the families associated in album
    public static let ALBUM_DOCUMENT_FIELD_OWNER = "owner_path" // the owner associated in album
    public static let ALBUM_DOCUMENT_FIELD_CREATED_DATE = "date_created" // the album's created date
    public static let ALBUM_DOCUMENT_FIELD_THUMBNAIL = "thumbnail" // album's photo thumbnail
    public static let ALBUM_DOCUMENT_FIELD_THUMBNAIL_EXTENSION = "thumbnail_extension" // album's photo thumbnail's extension

    
    /* constant for MEDIA collections */
    public static let MEDIA_COLLECTION_NAME = "media"
    public static let MEDIA_DOCUMENT_FIELD_WATCH = "watch" // # of watches
    public static let MEDIA_DOCUMENT_FIELD_LIKES = "likes" // # of likes
    public static let MEDIA_DOCUMENT_FIELD_COMMENTS = "comments" // comments field
    public static let MEDIA_DOCUMENT_FIELD_DESCRIPTION = "description" // description field
    public static let MEDIA_DOCUMENT_FIELD_EXTENSION = "extension" // file extension field
    public static let MEDIA_DOCUMENT_FIELD_CREATED_DATE = "date_created" // the media's created date
    public static let MEDIA_DOCUMENT_FIELD_ALBUM = "album_path" // reference back to album field
    
    //doc ID field:
    public static let DOCUMENTID = "documentID" 

    
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
    public func addNewAlbum(albumName : String, description: String,thumbnail : String,
                            thumbnailExt : String,
                            completion: @escaping (DocumentReference?) -> () ) {
        //        let familyUID = CacheHandler.getInstance().getCache(forKey: CacheHandler.FAMILY_KEY as AnyObject);
        //
        //        let familyDocRef  = DBController.getInstance().getDocumentReference(collectionName: RegisterDBController.FAMILY_COLLECTION_NAME, documentUID: familyUID as! String);
        //        print("fam doc ref at addNewAlbum:::  \(familyDocRef)" );

        //get currentUser's family
        let user = Auth.auth().currentUser!.uid
        let userDocumentReference = DBController.getInstance().getDocumentReference(collectionName: RegisterDBController.USER_COLLECTION_NAME, documentUID: user);
        DBController.getInstance()
            .getDocumentFromCollection(
                collectionName: RegisterDBController.USER_COLLECTION_NAME,
                documentUID: user)
            {  (document, error) in
                if let document = document, document.exists {
                    let familyDocRef:DocumentReference? = document.get(RegisterDBController.USER_DOCUMENT_FIELD_FAMILY) as! DocumentReference?

                    //                let familyDocumentReference:DocumentReference = DBController.getInstance().getDocumentReference(collectionName: RegisterDBController.FAMILY_COLLECTION_NAME, documentUID: familyUID as! String);

                    /*init new album
                     update: album has reference to family + owner/creator.
                     update: album has photo thumbnail + date created is stored.

                     */
                    
                    let albumDocumentReference:DocumentReference? = DBController.getInstance()
                        .addDocumentToCollection(
                            inputData: [
                                AlbumDBController.ALBUM_DOCUMENT_FIELD_NAME : albumName,
                                AlbumDBController.ALBUM_DOCUMENT_FIELD_MEDIAS : [],
                                AlbumDBController.ALBUM_DOCUMENT_FIELD_DESCRIPTION : description ,
                                AlbumDBController.ALBUM_DOCUMENT_FIELD_FAMILY : familyDocRef!,
                                AlbumDBController.ALBUM_DOCUMENT_FIELD_OWNER : userDocumentReference,
                                AlbumDBController.ALBUM_DOCUMENT_FIELD_THUMBNAIL : thumbnail,
                                AlbumDBController.ALBUM_DOCUMENT_FIELD_CREATED_DATE : Timestamp(date: Date()),
                                AlbumDBController.ALBUM_DOCUMENT_FIELD_THUMBNAIL_EXTENSION : thumbnailExt],
                            collectionName: AlbumDBController.ALBUM_COLLECTION_NAME);



                    /*add album to family*/
                    DBController.getInstance()
                        .updateArrayField(collectionName: RegisterDBController.FAMILY_COLLECTION_NAME,
                                          documentUID: familyDocRef!.documentID,
                                          fieldName: RegisterDBController.FAMILY_DOCUMENT_FIELD_ALBUM_PATHS, appendValue:albumDocumentReference! );

                    /*listens to album updates*/
                    //                self.addAlbumSnapshotListener(familyDocumentReference: familyDocRef!);

                    //returns the album's DocumentReference
                    completion(albumDocumentReference);





                } else {
                    print("ERROR at addNewAlbum::: ERROR RETRIEVING DOCUMENT: "+error!.localizedDescription)
                }
        }
        
        
        
        
    }
    //TODO: add/update album photo thumbnail::
    public func addAlbumThumbnail(albumUID : String, photoThumbnail : String, photoThumbnailExtension: String){
       
        DBController
            .getInstance()
            .updateSpecificField(
                newValue: photoThumbnail,
                fieldName: AlbumDBController.ALBUM_DOCUMENT_FIELD_THUMBNAIL,
                documentUID: albumUID,
                collectionName: AlbumDBController.ALBUM_COLLECTION_NAME);
        
        
        DBController
            .getInstance()
            .updateSpecificField(
                newValue: photoThumbnailExtension,
                fieldName: AlbumDBController.ALBUM_DOCUMENT_FIELD_THUMBNAIL_EXTENSION,
                documentUID: albumUID,
                collectionName: AlbumDBController.ALBUM_COLLECTION_NAME);
        
        
    }

    
    public func getAlbums(  familyDocumentReference:DocumentReference,  completion : @escaping ((QuerySnapshot?,Error?) -> ())){
       
        DBController
            .getInstance()
            .getDB()
            .collection(AlbumDBController.ALBUM_COLLECTION_NAME)
            .whereField(AlbumDBController.ALBUM_DOCUMENT_FIELD_FAMILY,
                        isEqualTo: familyDocumentReference as Any).getDocuments {(querysnapshot , error)  in
                            completion(querysnapshot, error);
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
    public func addPhotoToAlbum(desc : String, ext : String, albumUID : String, mediaPath:String, dateCreated : Timestamp){
        /*init new media
         * update: now has Date Created + reference to its own album */
        let albumDocRef :DocumentReference = DBController
            .getInstance()
            .getDocumentReference(
            collectionName:AlbumDBController.ALBUM_COLLECTION_NAME,
            documentUID: albumUID);
        DBController
            .getInstance()
            .addDocumentToCollectionWithUID(
                documentUID: mediaPath,
                inputData: [
                    AlbumDBController.MEDIA_DOCUMENT_FIELD_WATCH : 0,
                    AlbumDBController.MEDIA_DOCUMENT_FIELD_LIKES :0,
                    AlbumDBController.MEDIA_DOCUMENT_FIELD_COMMENTS: "",
                    AlbumDBController.MEDIA_DOCUMENT_FIELD_EXTENSION : ext,
                    AlbumDBController.MEDIA_DOCUMENT_FIELD_DESCRIPTION : desc,
                    AlbumDBController.MEDIA_DOCUMENT_FIELD_ALBUM : albumDocRef,
                    AlbumDBController.MEDIA_DOCUMENT_FIELD_CREATED_DATE : dateCreated],
                collectionName: AlbumDBController.MEDIA_COLLECTION_NAME);
        
        /*add path to album*/
        DBController.getInstance()
            .updateArrayField(
                collectionName: AlbumDBController.ALBUM_COLLECTION_NAME,
                documentUID: albumUID,
                fieldName: AlbumDBController.ALBUM_DOCUMENT_FIELD_MEDIAS,
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
                        .get(AlbumDBController.ALBUM_DOCUMENT_FIELD_MEDIAS) as! [String]
                    print("MediaFilePaths at getPhotosFromAlbum::: \(mediaFilePaths)");
                    
                    completion(mediaFilePaths);
                    
                   
                    
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
        //get all photos attached to this album:
        
        
        //remove reference from album:
        DBController.getInstance()
            .removeArrayField(
                collectionName: AlbumDBController.ALBUM_COLLECTION_NAME,
                documentUID: albumUID,
                fieldName: AlbumDBController.ALBUM_DOCUMENT_FIELD_MEDIAS,
                removeValue: mediaPath);
        
        //TODO: remove photo file from storage:
        DBController.getInstance().getDocumentFromCollection(collectionName: AlbumDBController.MEDIA_COLLECTION_NAME, documentUID: mediaPath) { (document, error) in
            let ext : String = document?.get(AlbumDBController.MEDIA_DOCUMENT_FIELD_EXTENSION) as! String;
            Util.DeleteFileFromServer(fileName: mediaPath, fextension: ext);
            
        }
        
        
        //delete media document from media collection:
        DBController.getInstance()
            .deleteWholeDocumentfromCollection(
                documentUID: mediaPath,
                collectionName: AlbumDBController.MEDIA_COLLECTION_NAME);
    }
    /// <#Description#>
    /// completely delete a whole album including its media files and thumbnail.
    /// - Parameters:
    ///   - albumUID: album's UID to be deleted.
    
    public func deleteAlbum(albumUID: String){
        
        let albumDocumentReference : DocumentReference =  DBController.getInstance().getDocumentReference(collectionName: AlbumDBController.ALBUM_COLLECTION_NAME, documentUID: albumUID);
        // get all media files:
        DBController
            .getInstance()
            .getDB()
            .collection(AlbumDBController.MEDIA_COLLECTION_NAME)
            .whereField(AlbumDBController.MEDIA_DOCUMENT_FIELD_ALBUM,
                        isEqualTo: albumDocumentReference as Any)
            .getDocuments { (querySnapshot, error) in
            querySnapshot?
            .documents
                //then, for each file::
            .forEach({ (doc) in
                
//                //delete from storage:
//            Util.DeleteFileFromServer(
//            fileName: doc.documentID,
//            fextension: doc.data()[AlbumDBController.MEDIA_DOCUMENT_FIELD_EXTENSION] as! String);
                //delete from db:
                DBController.getInstance().deleteWholeDocumentfromCollection(documentUID: doc.documentID, collectionName: AlbumDBController.MEDIA_COLLECTION_NAME);
                print("delted photo: \(doc.data())");
            })
                DBController.getInstance().getDocumentFromCollection(collectionName: AlbumDBController.ALBUM_COLLECTION_NAME, documentUID: albumUID, completion: { (document, error) in
                    //delete album thumbnail from storage, if there's any:

                        if (document!.data()?[AlbumDBController.ALBUM_DOCUMENT_FIELD_THUMBNAIL] != nil){
                            print("deleting thumbnail..");

                         Util.DeleteFileFromServer(fileName: document!.data()![AlbumDBController.ALBUM_DOCUMENT_FIELD_THUMBNAIL] as! String,
                        fextension: document!.data()![AlbumDBController.ALBUM_DOCUMENT_FIELD_THUMBNAIL_EXTENSION] as! String);
                        }
                    
                    

                });
                //delete album from db:
                DBController.getInstance().deleteWholeDocumentfromCollection(documentUID: albumUID, collectionName: AlbumDBController.ALBUM_COLLECTION_NAME);
                
                
                
                            
                           
        }
        
//        from storage: TODO: remove all photo files (related to the album) from storage:
//
//        //get all media file paths:
//        DBController.getInstance().getDocumentFromCollection(collectionName: AlbumDBController.ALBUM_COLLECTION_NAME, documentUID: albumUID) { (document, error) in
//
//            if let document = document, document.exists {
//                let mediaPaths:  NSArray = document.get(AlbumDBController.ALBUM_DOCUMENT_FIELD_MEDIA) as! NSArray ;
//
//
//                let x: DocumentReference;
//
//
//                //delete in DB:
//                mediaPaths.forEach({ (media) in
//                    DBController
//                        .getInstance()
//                        .deleteWholeDocumentfromCollection(
//                            documentUID: media as! String,
//                            collectionName: AlbumDBController.ALBUM_COLLECTION_NAME);
//                });
//
//                //delete in storage:
//
////                DBController.getInstance()
////                    .deleteWholeDocumentfromCollection(
////                        documentUID: albumUID,
////                        collectionName: AlbumDBController.ALBUM_COLLECTION_NAME);
////
//
//
//
        
//
//            } else {
//                print("ERROR at deleteAlbum::: ERROR RETRIEVING DOCUMENT: "+error!.localizedDescription)
//            }
//
//        print("run:::: ")
//        }
//
//
//    }
        
    }
    
}
