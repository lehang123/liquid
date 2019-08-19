//
//  CacheHandler.swift
//  ITProject
//
//  Created by Gilbert Vincenta on 19/8/19.
//  Copyright © 2019 liquid. All rights reserved.
//


import Foundation
import Firebase
import FirebaseCore
import FirebaseFirestore

/// <#Description#>
///Handles caching data for various Firebase services.
class CacheHandler {
    private static var single : CacheHandler!;
    init (){
        
        
    }
    public static func getInstance() -> CacheHandler{
        if (single == nil){
            single =  CacheHandler();
        }
        return single;
    }
    public func checkPendingWrites(collectionName: String, documentUID: String){
        DBController.getInstance().addSnapshotListener(collectionName: collectionName, documentUID: documentUID) { (documentSnapshot, error) in
            guard let document = documentSnapshot else {
                print("checkPendingWrites ::: Error fetching document: \(error!)")
                return
            }
            let source = document.metadata.hasPendingWrites ? "Local" : "Server"
            print("checkPendingWrites ::: \(source) data: \(document.data() ?? [:])")
        };
    
    }
    
    
    
        
        
      
        
    
}
    
    
    

    
    
    


