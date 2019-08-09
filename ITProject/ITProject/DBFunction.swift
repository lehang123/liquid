//
//  DBFunction.swift
//  ITProject
//
//  Created by Gilbert Vincenta on 9/8/19.
//  Copyright © 2019 liquid. All rights reserved.
//
// codes adapted from : https://firebase.google.com/docs/firestore/quickstart
import Foundation

import FirebaseCore
import FirebaseFirestore


// Add a new document with a generated ID
var ref: DocumentReference? = nil
class DBFunction{
    //var db: Firestore!
    //db = Firestore.firestore()
    public static func AddUser (username : String) -> Void{
        ref = db.collection("users").addDocument(data: [
            "username" : username
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(ref!.documentID)")
            }
        }

    }
    
    
}

