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
    
    
    /// <#Description#>
    /// increments object counter.
    private static func addObjects(){
        dataObjects+=1;

    }
    
    
    /// <#Description#>
    /// increments cache storage counter.
    private static func addCacheCounter(){
        
        cachedCounter+=1;

    }
    
    /// <#Description#>
    /// stores an object into NSCache's dictionary.
    /// note that if you set object into same key again,
    ///it'll replace the existing object with the new "obj". (i.e. update instead of create).
    /// - Parameters:
    ///   - obj: object to be stored
    ///   - forKey: key of the object
    public func setCache (obj: AnyObject, forKey: AnyObject){
        
        self.dataCache.setObject( obj, forKey: forKey);
        CacheHandler.addCacheCounter();
    }
    
    
    /// <#Description#>
    /// gets an object from cache by its key.
    /// - Parameter forKey: key of the object
    /// - Returns: the object associated with the key given
    public func getCache (forKey: AnyObject) -> AnyObject{
        
        return self.dataCache.object(forKey: forKey)!;
        
    }
    /// <#Description#>
    /// removes all objects in cache. be mindful of this when working with others,
    /// as the cache is apparently in singleton manner.
    public func cleanCache(){
        self.dataCache.removeAllObjects();
    }
    
    /// <#Description#>
    /// removes 1 object with associated key.
    /// - Parameter forKey: key of the object to be removed.
    public func removeFromCache(forKey: AnyObject){
        self.dataCache.removeObject(forKey: forKey);
    }
    
    
    
    /*using NSDiscardableContent's protocol for data that has short lifecycles:*/
    
    /// <#Description#>
    /// sets a NSDiscardableContent object into cache.
    /// - Parameters:
    ///   - obj: object to be inserted
    ///   - forKey: object's associated key
    public func setDiscardableCache(obj: NSDiscardableContent, forKey: AnyObject){
        
        
        self.dataCache.setObject( obj, forKey:forKey );
    }
    
    /// <#Description#>
    ///gets a NSDiscardableContent object from cache.
    /// - Parameter forKey: object's associated key
    /// - Returns:the stored object in NSDiscardableContent type
    public func getDiscardableCache( forKey: AnyObject) ->NSDiscardableContent{
        var x:Bool  = self.dataCache.object(forKey: forKey)!.beginContentAccess();
        return self.dataCache.object(forKey: forKey)! as! NSDiscardableContent;
        
    }
    
    /// <#Description#>
    /// use this finished after accessing a NSDiscardableContent object so that
    /// it can be removed when it's no longer needed.
    /// - Parameter forKey: object's associated key
    public func finishDiscardableAccess( forKey: AnyObject){
         self.dataCache.object(forKey: forKey)!.endContentAccess();
        
    }
    
    /// <#Description#>
    ///tries to safely remove a NSDiscardableContent object.
    /// - Parameter forKey: object's associated key to be removed.
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
    
    
    

    
    
    


