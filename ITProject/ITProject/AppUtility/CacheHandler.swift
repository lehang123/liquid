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
///Handles caching data.
class CacheHandler {
    
    private var dataCache :NSCache<AnyObject, AnyObject>;
    private static var cachedCounter : Int = 0;  // keeps track of cachedData load. useful to check for limit later on.
    private static var dataObjects : Int = 0; // keeps track of # of objects ofCacheHandler.
    
    private static var single:CacheHandler!;
    init (){

        dataCache = NSCache<AnyObject, AnyObject>()
        CacheHandler.addObjects();

    }
    
    /// <#Description#>
    /// singleton pattern:
    /// - Returns: return an instance of this CacheHandler.
    public static func getInstance() -> CacheHandler{
        if (single == nil){
            single = CacheHandler()
        }
        return single;
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
    public func cleanCache(){
        self.dataCache.removeAllObjects();
    }
    
    public func removeFromCache(forKey: AnyObject){
        self.dataCache.removeObject(forKey: forKey);
    }
    
    
    /*using NSDiscardableContent's protocol for data that has short lifecycles:*/
    
    public func setDiscardableCache(obj: NSDiscardableContent, forKey: AnyObject){
        
        
        self.dataCache.setObject( obj, forKey:forKey );
    }
    
    public func getDiscardableCache( forKey: AnyObject) ->NSDiscardableContent{
        var x:Bool  = self.dataCache.object(forKey: forKey)!.beginContentAccess();
        return self.dataCache.object(forKey: forKey)! as! NSDiscardableContent;
        
    }
    
    public func finishDiscardableAccess( forKey: AnyObject){
         self.dataCache.object(forKey: forKey)!.endContentAccess();
        
    }
    
    public func enhanceMemory( forKey: AnyObject){
        let willDiscard:NSDiscardableContent = self.dataCache.object(forKey: forKey) as! NSDiscardableContent;
        
        willDiscard.discardContentIfPossible();
        
        
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
    
    
    

    
    
    


