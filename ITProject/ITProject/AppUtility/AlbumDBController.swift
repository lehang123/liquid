//
//  AlbumDBController.swift
//  ITProject
//
//  Created by Gilbert Vincenta on 16/8/19.
//  Copyright © 2019 liquid. All rights reserved.
//

import Foundation

import Firebase


class AlbumDBController {
    
    private static var single: AlbumDBController!;
    /* constant for ALBUMS collections */
    public static let ALBUM_COLLECTION_NAME = "albums"
    
    public static let ALBUM_DOCUMENT_FIELD_NAME = "name" // album's name
    public static let ALBUM_DOCUMENT_FIELD_DESCRIPTION = "description" // album's description

    public static let ALBUM_DOCUMENT_FIELD_MEDIA = "media_file_paths" // the media files associated

    
    /* constant for MEDIA collections */
    public static let MEDIA_COLLECTION_NAME = "media"
    public static let MEDIA_DOCUMENT_FIELD_WATCH = "watch" // # of watches
    public static let MEDIA_DOCUMENT_FIELD_LIKES = "likes" // # of likes
    public static let MEDIA_DOCUMENT_FIELD_COMMENTS = "comments" // comments field
    public static let MEDIA_DOCUMENT_FIELD_DESCRIPTION = "description" // description field
    public static let MEDIA_DOCUMENT_FIELD_EXTENSION = "extension" // file extension field

//    private var storage:Storage;
//    private var storageRef:StorageReference;
//
    init (){
//         storage = Storage.storage()
//        storageRef = storage.reference()
//

    }
    public static func getInstance() -> AlbumDBController{
        if (single == nil){
            single = AlbumDBController()
        }
        return single;
    }
    
    public func addNewAlbum(albumName : String, description: String){
        //get currentUser's family
        let user = Auth.auth().currentUser!.uid
        DBController.getInstance().getDocumentFromCollection(collectionName: RegisterDBController.USER_COLLECTION_NAME, documentUID:  user)
        {  (document, error) in
            if let document = document, document.exists {
                let familyDocRef:DocumentReference? = document.get(RegisterDBController.USER_DOCUMENT_FIELD_FAMILY) as! DocumentReference?
                
//                let familyDocumentReference:DocumentReference = DBController.getInstance().getDocumentReference(collectionName: RegisterDBController.FAMILY_COLLECTION_NAME, documentUID: familyUID as! String);
                print("got::: \(user) with fam : \(familyDocRef)" )
                
                        /*init new album */
                let albumDocumentReference =  DBController.getInstance().addDocumentToCollection(inputData: [AlbumDBController.ALBUM_DOCUMENT_FIELD_NAME : albumName, AlbumDBController.ALBUM_DOCUMENT_FIELD_MEDIA : [], AlbumDBController.ALBUM_DOCUMENT_FIELD_DESCRIPTION : description ], collectionName: AlbumDBController.ALBUM_COLLECTION_NAME);
                
                
                        /*add album to family*/
                        DBController.getInstance().updateArrayField(collectionName: RegisterDBController.FAMILY_COLLECTION_NAME, documentUID: familyDocRef!.documentID, fieldName: RegisterDBController.FAMILY_DOCUMENT_FIELD_ALBUM_PATHS, appendValue:albumDocumentReference );
                
                
            } else {
                print("ERROR::: ERROR RETRIEVING DOCUMENT")
            }
        
        }

        
    }
    // mediaPath is assumed to be unique
    public func addPhotoToAlbum(desc : String, ext : String, albumUID : String, mediaPath:String){
        /*init new media */
        DBController.getInstance().addDocumentToCollectionWithUID(documentUID: mediaPath, inputData: [ AlbumDBController.MEDIA_DOCUMENT_FIELD_WATCH : 0, AlbumDBController.MEDIA_DOCUMENT_FIELD_LIKES :0, AlbumDBController.MEDIA_DOCUMENT_FIELD_COMMENTS: "", AlbumDBController.MEDIA_DOCUMENT_FIELD_EXTENSION : ext, AlbumDBController.MEDIA_DOCUMENT_FIELD_DESCRIPTION : desc], collectionName: AlbumDBController.MEDIA_COLLECTION_NAME)
        
        /*add path to album*/
         DBController.getInstance().updateArrayField(collectionName: AlbumDBController.ALBUM_COLLECTION_NAME, documentUID: albumUID, fieldName: AlbumDBController.ALBUM_DOCUMENT_FIELD_MEDIA, appendValue:mediaPath );
    }
    
}

