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
   
    private var db: Firestore!
    private static var single: DBController!
    init (){
        db = Firestore.firestore()
    }
    
    public func getDB() -> Firestore{
    return self.db;
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
    
    public func getDocumentReference(collectionName : String, documentUID: String) -> DocumentReference{
        return self.db.collection(collectionName).document(documentUID);
    }
    
    public func getDocumentFromCollection(collectionName : String, documentUID: String, completion: @escaping (DocumentSnapshot?, Error?) -> ()){
        
        let docRef = db.collection(collectionName).document(documentUID)
        
        docRef.getDocument { (document, error) in
            completion(document, error)
        }
    }
    
    public func addDocumentToCollectionWithUID( documentUID : String, inputData: Dictionary<String, Any>, collectionName : String){
//        self.db.collection(collectionName).document(documentUID).setData(inputData) { err in
//            if let err = err {
//                print("test Error writing document: \(err)")
//            } else {
//                print(" test Document successfully written!")
//            }
//        }
        self.getDocumentReference(collectionName: collectionName, documentUID: documentUID).setData(inputData) { err in
                        if let err = err {
                            print("\(collectionName) ::: Error writing document: \(err)")
                        } else {
                            print("\(collectionName) ::: Document with UID:  \(documentUID) successfully written!")
                        }
                    }
        
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
                    print("\(collectionName) ::: Error writing document: \(err)")
                } else {
                    print(  "\(collectionName ) ::: Document with UID:  \(ref!.documentID) successfully written! ")
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
    public func updateSpecificField(newValue: Any,fieldName: String, documentUID : String, collectionName : String){
        db.collection(collectionName).document(documentUID).updateData([
            fieldName: newValue,
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
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
