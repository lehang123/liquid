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
    public static let FAMILY_FIELD = ["familyname", "username"]
    public static let USER_FIELD = ["username" ]
    
    /* constant for USERS collections */
    public static let USER_COLLECTION_NAME = "users"
    public static let USER_COLLECTION_FIELD_NAME = "name"
    public static let USER_COLLECTION_FIELD_FAMILY = "family"

    /* constant for FAMILIES collections */
    public static let FAMILY_COLLECTION_NAME = "families"
    public static let FAMILY_DOCUMENT_FIELD_NAME = "name"
    public static let FAMILY_DOCUMENT_FIELD_MEMBERS = "family_members"
    
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
            RegisterDBController.USER_COLLECTION_FIELD_NAME :username,
            RegisterDBController.USER_COLLECTION_FIELD_FAMILY :familyDocumentReference
            ], collectionName :
            RegisterDBController.USER_COLLECTION_NAME);
        
    }
    
    
    public func AddNewFamily(  familyName:String, userUID: String, username: String) -> DocumentReference{
        let userDocumentReference = DBController.getInstance().getDocumentReference(collectionName: RegisterDBController.USER_COLLECTION_NAME, documentUID: userUID)
        // creates  new family
        let familyUID = DBController.getInstance().addDocumentToCollection(inputData: [RegisterDBController.FAMILY_DOCUMENT_FIELD_NAME : familyName, RegisterDBController.FAMILY_DOCUMENT_FIELD_MEMBERS : [userDocumentReference]], collectionName: RegisterDBController.FAMILY_COLLECTION_NAME);
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
