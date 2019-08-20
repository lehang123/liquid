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
import UIKit

/// <#Description#>
///Handles caching data for various Firebase services.
class CacheHandler {
    
    private var dataCache :NSCache<AnyObject, AnyObject>;
    private static var cachedCounter : Int = 0;  // keeps track of cachedData load. useful to check for limit later on.
    private static var dataObjects : Int = 0; // keeps track of # of objects ofCacheHandler.
    init (){

         dataCache = NSCache<AnyObject, AnyObject>()
        CacheHandler.addObjects();

    }
    
    private static func addObjects(){
        dataObjects+=1;

    }
    private static func addCacheCounter(){
        
        cachedCounter+=1;

    }
    
    public func setCache (obj: AnyObject, forKey: AnyObject){
        
        self.dataCache.setObject( obj, forKey: forKey);
        CacheHandler.addCacheCounter();
    }
    public func getCache (forKey: AnyObject) -> AnyObject{
        
        return self.dataCache.object(forKey: forKey)!;
        
    }

//    public func checkPendingWrites(collectionName: String, documentUID: String){
//        DBController.getInstance().addSnapshotListener(collectionName: collectionName, documentUID: documentUID) { (documentSnapshot, error) in
//            guard let document = documentSnapshot else {
//                print("checkPendingWrites ::: Error fetching document: \(error!)")
//                return
//            }
//            let source = document.metadata.hasPendingWrites ? "Local" : "Server"
//            print("checkPendingWrites ::: \(source) data: \(document.data() ?? [:])")
//        };
//
//    }
    
}
    
    
    

    
    
    


