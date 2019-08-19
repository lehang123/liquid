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

/// <#Description#>
///DBController to read,add,update,delete data in Firestore DB with singleton pattern.
class DBController {
   
    private var db: Firestore!
    private static var single: DBController!
    init (){
        db = Firestore.firestore()
    }
    
    public func getDB() -> Firestore{
        return self.db;
    }
    
    /// <#Description#>
    /// singleton pattern:
    /// - Returns: return an instance of this dbcontroller.
    public static func getInstance() -> DBController{
        if (single == nil){
            single = DBController()
        }
        return single;
    }
    
    /// sanitise input into DB. basically checks if the fieldName is correct or not.
    /// implementation will be added soon.
    
    /// <#Description#>
    /// gives a DocumentReference instance of the document.
    /// - Parameters:
    ///   - collectionName: the collection that stores the document.
    ///   - documentUID: the name of the document you wanna retrieve.
    /// - Returns: a DocumentReference instance of the document you are retrieving.
    public func getDocumentReference(collectionName : String, documentUID: String) -> DocumentReference{
        return self.db.collection(collectionName).document(documentUID);
    }
    
    public func addSnapshotListener(collectionName: String, documentUID: String,  completion: @escaping (DocumentSnapshot?, Error?) -> ()){
        
        self.getDocumentReference(collectionName: collectionName, documentUID: documentUID)
            .addSnapshotListener {(document, error) in
                
                completion(document, error);
             
        }
        
        
    }
    
    /// <#Description#>
    /// gives a DocumentSnapshot instance of the document at completion.
    /// - Parameters:
    ///   - collectionName: the collection that stores the document.
    ///   - documentUID: the UID of the document you wanna retrieve.
    ///   - completion: further tasks you wanna do with the returned DocumentSnapshot instance.
    public func getDocumentFromCollection(collectionName : String, documentUID: String, completion: @escaping (DocumentSnapshot?, Error?) -> ()){
        
        let docRef = self.getDocumentReference(collectionName: collectionName, documentUID: documentUID)
        
        docRef.getDocument { (document, error) in
            completion(document, error)
        }
    }
    
    /// <#Description#>
    /// inserts a document with pre-specified UID.
    /// - Parameters:
    ///   - documentUID: pre-specified UID for the new document.
    ///   - inputData: the attributes and their values to be added for new document.
    ///   - collectionName: the collection you wanna add the document into.
    public func addDocumentToCollectionWithUID( documentUID : String, inputData: Dictionary<String, Any>, collectionName : String){

        self.getDocumentReference(collectionName: collectionName, documentUID: documentUID).setData(inputData) { err in
                        if let err = err {
                            print("\(collectionName) ::: Error adding document: \(err)")
                        } else {
                            print("\(collectionName) ::: Document with UID:  \(documentUID) successfully written!")
                        }
                    }
        
    }
    

    /// add 1 document to 1 collection. prints out "Error" if error found,
    /// otherwise prints out document's ID.
    /// <#Description#>
    /// add 1 document to 1 collection with an automatically generated UID,
    /// - Parameters:
    ///    - inputData: the attributes and their values to be added for new document.
    ///    - collectionName: the collection you wanna add the document into.
    /// - Returns: a DocumentReference instance of the added document.
    public func addDocumentToCollection (inputData: Dictionary<String, Any>, collectionName : String) -> DocumentReference {
        var ref: DocumentReference? = nil
        
        ref = db.collection(collectionName).addDocument(data: inputData){ err in
            if let err = err {
                print("\(collectionName) ::: Error writing document: \(err)")
            } else {
                print("\(collectionName ) ::: Document with (prespecified) UID: \(ref!.documentID) successfully written! ")
            }
        }
    
        return ref!;
    }
    
    /// Description
    /// remove11 document from 1 collection. prints out "Error" if error found,
    /// otherwise prints out success message.
    /// - Parameters:
    ///   - documentUID: The document's UID to be deleted from DB.
    ///   - collectionName: the collection you want to delete from.
    public func deleteWholeDocumentfromCollection(documentUID : String, collectionName : String){
        self.getDocumentReference(collectionName: collectionName, documentUID: documentUID).delete() { err in
            if let err = err {
                print("Error::: error removing document: \(err)")
            } else {
                print("\(collectionName)::: Document \(documentUID)  successfully removed!")
            }
        }
    }
    /// Description
    /// update 1 document's field from 1 collection. prints out "Error" if error found,
    /// otherwise prints out success message. note that the fieldName
    ///must exist inside document prior updating.
    /// - Parameters:
    ///   - documentUID: The document's UID to be updated.
    ///   - collectionName: the collection you want to update into.
    ///   - newValue : the new value to be added into the field.
    ///   - fieldName : the name of the field you want to update.
    public func updateSpecificField(newValue: Any,fieldName: String, documentUID : String, collectionName : String){
        self.getDocumentReference(collectionName: collectionName, documentUID: documentUID).updateData([
            fieldName: newValue,
        ]) { err in
            if let err = err {
                print("\(collectionName) ::: Error updating document: \(err)")
            } else {
                print("\(collectionName) ::: Document \(documentUID) successfully updated its  \(fieldName) field")
            }
        }
        
    }
    
    /// <#Description#>
    /// appends a value into a field with array data type.
    /// - Parameters:
    ///   - fieldName : the name of the (array) field you want to update.
    ///   - appendValue: the new value to be appemnded into the array field.
    ///   - documentUID: The document's UID to be updated.
    ///   - collectionName: the collection you want to update into.
    public func updateArrayField(collectionName: String, documentUID:String, fieldName : String, appendValue : Any ){
        self.getDocumentReference(collectionName: collectionName, documentUID: documentUID).updateData([fieldName :  FieldValue.arrayUnion([ appendValue ]) ]){ err in
            if let err = err {
                print("\(collectionName) ::: Error updating document with array field: \(err)")
            } else {
                print("\(collectionName) ::: Document  \(documentUID) with array field \(fieldName) successfully updated")
            }
        };
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
