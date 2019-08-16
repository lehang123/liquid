//
//  Util.swift
//  ITProject
//
//  Created by Gilbert Vincenta on 9/8/19.
//  Copyright © 2019 liquid. All rights reserved.
//

import Foundation
import Firebase
import FirebaseCore
import FirebaseFirestore

class RegisterDBController {
    
    /* constant for USERS collections */
    public static let USER_COLLECTION_NAME = "users"
    public static let USER_DOCUMENT_FIELD_NAME = "name" // user's name
    public static let USER_DOCUMENT_FIELD_FAMILY = "family" // user's family reference
    public static let USER_DOCUMENT_FIELD_POSITION = "position" // user's position in family


    /* constant for FAMILIES collections */
    public static let FAMILY_COLLECTION_NAME = "families"
    
    public static let FAMILY_DOCUMENT_FIELD_NAME = "name" // family name
    public static let FAMILY_DOCUMENT_FIELD_MEMBERS = "family_members" // the members
    public static let FAMILY_DOCUMENT_FIELD_ALBUM_PATHS = "album_paths" // paths to album
    public static let FAMILY_DOCUMENT_FIELD_MOTTO = "motto" // family's motto
    public static let FAMILY_DOCUMENT_FIELD_PROFILE_PICTURE = "profile_picture" // paths to family profile pict

    
    public static let USER_COLLECTION_PATH = NSString ("users/")
    public static let FAMILY_COLLECTION_PATH = NSString ("families/")
    
    private static var single: RegisterDBController!;
    
    init (){
        
    }
    public static func getInstance() -> RegisterDBController{
        if (single == nil){
            single = RegisterDBController()
        }
        return single;
    }
    
    public func AddUser(familyUID : String, userUID: String, username: String){
        let familyDocumentReference = DBController.getInstance().getDocumentReference(collectionName: RegisterDBController.FAMILY_COLLECTION_NAME, documentUID: familyUID);
        DBController.getInstance().addDocumentToCollectionWithUID( documentUID : userUID, inputData:[
            RegisterDBController.USER_DOCUMENT_FIELD_NAME :username,
            RegisterDBController.USER_DOCUMENT_FIELD_FAMILY :familyDocumentReference,
            RegisterDBController.USER_DOCUMENT_FIELD_POSITION : ""], collectionName :
            RegisterDBController.USER_COLLECTION_NAME);
        
    }
    
    
    public func AddNewFamily(  familyName:String, userUID: String, username: String) -> DocumentReference{
        let userDocumentReference = DBController.getInstance().getDocumentReference(collectionName: RegisterDBController.USER_COLLECTION_NAME, documentUID: userUID)
        // creates  new family
        let familyUID = DBController.getInstance().addDocumentToCollection(inputData:
            [RegisterDBController.FAMILY_DOCUMENT_FIELD_NAME : familyName,
            RegisterDBController.FAMILY_DOCUMENT_FIELD_MEMBERS : [userDocumentReference],
            RegisterDBController.FAMILY_DOCUMENT_FIELD_ALBUM_PATHS : [],
                RegisterDBController.FAMILY_DOCUMENT_FIELD_MOTTO :"",
                RegisterDBController.FAMILY_DOCUMENT_FIELD_PROFILE_PICTURE : ""], collectionName: RegisterDBController.FAMILY_COLLECTION_NAME);
        return familyUID;
        
        
    }
    
    public func AddUserToExistingFamily( familyUID: String, userUID: String) {
        let userDocumentReference = DBController.getInstance().getDocumentReference(collectionName: RegisterDBController.USER_COLLECTION_NAME, documentUID: userUID)
        let familyDocumentReference =
            DBController.getInstance().getDocumentReference(collectionName: RegisterDBController.FAMILY_COLLECTION_NAME, documentUID: familyUID)
        
        familyDocumentReference.updateData([RegisterDBController.FAMILY_DOCUMENT_FIELD_MEMBERS :  FieldValue.arrayUnion([userDocumentReference]) ]){ err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
            }
        };
    }
    
    
    
}
