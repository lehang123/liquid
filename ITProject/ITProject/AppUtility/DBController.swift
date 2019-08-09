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

class DBController {
    public static let FAMILY_FIELD = ["familyname", "username"]
    public static let USER_FIELD = ["username" ]
    private var db: Firestore!
    init(){
        //initiate db instance
        db = Firestore.firestore()
        
    }
    
    public func validate(inputData: Dictionary<String, String>) -> Bool{
        return false;
    }
    
    public func addDocumentToCollection (inputData: Dictionary<String, String>, collectionName : String) {
        var ref: DocumentReference? = nil
        if (self.validate(inputData: inputData) == true) {
            ref = db.collection(collectionName).addDocument(data: inputData)
            { err in
                if let err = err {
                    print("Error adding document: \(err)")
                } else {
                    print("Document added with ID: \(ref!.documentID)")
                }
            }
        }
        
    }
    public func deleteWholeDocumentfromCollection(documentName : String, collectionName : String){
        db.collection(collectionName).document(documentName).delete() { err in
            if let err = err {
                print("Error removing document: \(err)")
            } else {
                print("Document successfully removed!")
            }
        }
    }
    
    public func updateSpecificField(newValue: Any,fieldName: String, documentName : String, collectionName : String){
        db.collection(collectionName).document(documentName).updateData([
            fieldName: newValue,
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
            }
        }
    
    }
    public func getDatafromDocument(documentName : String, collectionName : String){
       db.collection(collectionName).document(documentName).getDocument { (document, error) in
            if let document = document, document.exists {
                let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                print("Document data: \(dataDescription)")
            } else {
                print("Document does not exist")
            }
        }

        
    }

    public func getDataQuery(fieldName : String){
//        db.collection(collectionName).whereField(field, isEqualTo: true)
//            .getDocuments() { (querySnapshot, err) in
//                if let err = err {
//                    print("Error getting documents: \(err)")
//                } else {
//                    for document in querySnapshot!.documents {
//                        print("\(document.documentID) => \(document.data())")
//                    }
//                }
//        }

    }
    
    
    
}
