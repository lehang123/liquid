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
    public static let USER_COLLECTION_NAME = "users"
    public static let FAMILY_COLLECTION_NAME = "families"
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
            "name" :username,
            "family" :familyDocumentReference
            ], collectionName :
            RegisterDBController.USER_COLLECTION_NAME);
        
    }
    
    
    public func AddNewFamily(  familyName:String, userUID: String, username: String) -> DocumentReference{
        let userDocumentReference = DBController.getInstance().getDocumentReference(collectionName: RegisterDBController.USER_COLLECTION_NAME, documentUID: userUID)
        // creates  new family
        let familyUID = DBController.getInstance().addDocumentToCollection(inputData: ["name" : familyName, "family_members" : [userDocumentReference]], collectionName: RegisterDBController.FAMILY_COLLECTION_NAME);
        return familyUID;
        
        
    }
    
    public func AddUserToExistingFamily( familyUID: String, userUID: String) {
          let userDocumentReference = DBController.getInstance().getDocumentReference(collectionName: RegisterDBController.USER_COLLECTION_NAME, documentUID: userUID)
        let familyDocumentReference =
            DBController.getInstance().getDocumentReference(collectionName: RegisterDBController.FAMILY_COLLECTION_NAME, documentUID: familyUID)
        
        familyDocumentReference.updateData(["family_members" :  FieldValue.arrayUnion([userDocumentReference]) ]);
    }
    
}
