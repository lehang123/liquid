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
    private static var single: DBController!
    private var reference : QueryDocumentSnapshot?
    init (){
        db = Firestore.firestore()
        reference = nil
    }
    
    public static func getInstance() -> DBController{
        if (single == nil){
            single = DBController()
        }
        return single;
    }
    
    /// <#Description#>
    /// sanitise input into DB. basically checks if the fieldName is correct or not.
    /// implementation will be added soon.
    /// - Parameters:
    ///   - inputData: The data to be checked.
    public func validate(inputData: Dictionary<String, Any>) -> Bool{
        return true ;
    }
    
    /// <#Description#>
    /// add 1 document to 1 collection. prints out "Error" if error found,
    /// otherwise prints out document's ID.
    /// - Parameters:
    ///   - inputData: The data to be inserted into DB.
    ///   - collectionName: the collection you want to insert into.
    public func addDocumentToCollection (inputData: Dictionary<String, Any>, collectionName : String) -> DocumentReference {
        var ref: DocumentReference? = nil
        if (self.validate(inputData: inputData) == true) {
            ref = db.collection(collectionName).addDocument(data: inputData)
            { err in
                if let err = err {
                    print("Error adding document: \(err)")
                } else {
                    print(  " added into \(collectionName ) ::: Document added with ID: \(ref!.documentID)")
                }
            }
        }
        return ref!;
    }
    
    /// Description
    /// remove 1 document from 1 collection. prints out "Error" if error found,
    /// otherwise prints out success message.
    /// - Parameters:
    ///   - documentName: The document's name to be deleted from DB.
    ///   - collectionName: the collection you want to delete from.
    /// bug 
    public func deleteWholeDocumentfromCollection(documentName : String, collectionName : String){
        db.collection(collectionName).document(documentName).delete() { err in
            if let err = err {
                print("Error removing document: \(err)")
            } else {
                print("Document \(documentName)  successfully removed! from \(collectionName)")
            }
        }
    }
    /// Description
    /// update 1 document's field from 1 collection. prints out "Error" if error found,
    /// otherwise prints out success message.
    /// - Parameters:
    ///   - documentName: The document's name to be updated into DB.
    ///   - collectionName: the collection you want to update into.
    ///   - newValue : the new value to be added into the field.
    ///   - fieldName : the name of the field you want to update.
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
    
   
    
    /// Description
    /// get 1 document's from 1 collection. prints out "Does not exist" if not found,
    /// otherwise prints out the data.
    /// - Parameters:
    ///   - documentName: The document's name to be retrieved from  DB.
    ///   - collectionName: the collection you want to retrieve from.
    /// need to handle async! 
    public func getDatafromDocument(fieldName : String, documentName : String, collectionName : String){
//        var querySnapshotResult:QueryDocumentSnapshot?;
//
//         db.collection(collectionName).whereField(fieldName, isEqualTo: documentName).getDocuments(completion: {
//
//
//            }}){
//                completion();
//
//        }
//        querySnapshotResult = self.reference;
        // either return querySnapshotResult OR somethingelse
//        return querySnapshotResult;
    
        //        let docRef = db.collection(collectionName).document(documentName)
        //
        //        docRef.getDocument { (document, error) in
        //            if let document = document, document.exists {
        //                let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
        //                print("Document data: \(dataDescription)")
        //            } else {
        //                print("Document does not exist")
        //            }
        //        }
        
        
        
        //var querySnapshotResult:QuerySnapshot?  = nil;
        
        
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
