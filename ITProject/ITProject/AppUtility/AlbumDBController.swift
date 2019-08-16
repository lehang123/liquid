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
    ///   - albumName: the name of album to be created.
    ///   - description: the album's (short) description.
    public func addNewAlbum(albumName : String, description: String){
        //get currentUser's family
        let user = Auth.auth().currentUser!.uid
        DBController.getInstance().getDocumentFromCollection(collectionName: RegisterDBController.USER_COLLECTION_NAME, documentUID:  user)
        {  (document, error) in
            if let document = document, document.exists {
                let familyDocRef:DocumentReference? = document.get(RegisterDBController.USER_DOCUMENT_FIELD_FAMILY) as! DocumentReference?
                
//                let familyDocumentReference:DocumentReference = DBController.getInstance().getDocumentReference(collectionName: RegisterDBController.FAMILY_COLLECTION_NAME, documentUID: familyUID as! String);
                
                        /*init new album */
                let albumDocumentReference =  DBController.getInstance().addDocumentToCollection(inputData: [AlbumDBController.ALBUM_DOCUMENT_FIELD_NAME : albumName, AlbumDBController.ALBUM_DOCUMENT_FIELD_MEDIA : [], AlbumDBController.ALBUM_DOCUMENT_FIELD_DESCRIPTION : description ], collectionName: AlbumDBController.ALBUM_COLLECTION_NAME);
                
                
                        /*add album to family*/
                        DBController.getInstance().updateArrayField(collectionName: RegisterDBController.FAMILY_COLLECTION_NAME, documentUID: familyDocRef!.documentID, fieldName: RegisterDBController.FAMILY_DOCUMENT_FIELD_ALBUM_PATHS, appendValue:albumDocumentReference );
                
                
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
    ///   - mediaPath:  the media file's path to be inserted ( unique).
    public func addPhotoToAlbum(desc : String, ext : String, albumUID : String, mediaPath:String){
        /*init new media */
        DBController.getInstance().addDocumentToCollectionWithUID(documentUID: mediaPath, inputData: [ AlbumDBController.MEDIA_DOCUMENT_FIELD_WATCH : 0, AlbumDBController.MEDIA_DOCUMENT_FIELD_LIKES :0, AlbumDBController.MEDIA_DOCUMENT_FIELD_COMMENTS: "", AlbumDBController.MEDIA_DOCUMENT_FIELD_EXTENSION : ext, AlbumDBController.MEDIA_DOCUMENT_FIELD_DESCRIPTION : desc], collectionName: AlbumDBController.MEDIA_COLLECTION_NAME)
        
        /*add path to album*/
         DBController.getInstance().updateArrayField(collectionName: AlbumDBController.ALBUM_COLLECTION_NAME, documentUID: albumUID, fieldName: AlbumDBController.ALBUM_DOCUMENT_FIELD_MEDIA, appendValue:mediaPath );
    }
    
}

