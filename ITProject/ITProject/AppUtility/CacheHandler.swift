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
class CacheHandler : NSObject {
    
    private var dataCache :NSCache<NSString, NSData>;
    private static var cachedCounter : Int = 0;  // keeps track of cachedData load. useful to check for limit later on.
    private static var dataObjects : Int = 0; // keeps track of # of objects ofCacheHandler.
    
    // *** deprecated : now cache will be used to store image only
    public static let FAMILY_KEY:String = "familyUID";
    public static let USER_DATA:String = "userData";
    public static let FAMILY_DATA:String = "familyData";
    public static let ALBUM_DATA:String = "albumData";


    private static var single:CacheHandler!;
    override init (){
        dataCache = NSCache<NSString, NSData>()
        super.init()
        dataCache.delegate = self
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
    public func setCache (obj: Data, forKey: String){
        
        self.dataCache.setObject( obj as NSData, forKey: forKey as NSString);
        CacheHandler.addCacheCounter();
        print("setCache::: caching : \(obj) with key : \(forKey) succeeded.");
    }
    
    
    /// <#Description#>
    /// gets an object from cache by its key.
    /// - Parameter forKey: key of the object
    /// - Returns: the object associated with the key given
    public func getCache (forKey: String) -> Data?{
        if let data = self.dataCache.object(forKey: forKey as NSString){
            return data as Data
        }else{
            return nil
        }
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
    public func removeFromCache(forKey: String){
        self.dataCache.removeObject(forKey: forKey as NSString);
    }
    
    
    
    /*using NSDiscardableContent's protocol for data that has short lifecycles:*/
    
//    /// <#Description#>
//    /// sets a NSDiscardableContent object into cache.
//    /// - Parameters:
//    ///   - obj: object to be inserted
//    ///   - forKey: object's associated key
//    public func setDiscardableCache(obj: NSDiscardableContent, forKey: String){
//
//        self.dataCache.setObject( obj as! NSData, forKey:forKey as NSString );
//    }
//
//    /// <#Description#>
//    ///gets a NSDiscardableContent object from cache.
//    /// - Parameter forKey: object's associated key
//    /// - Returns:the stored object in NSDiscardableContent type
//    public func getDiscardableCache( forKey: String) ->NSDiscardableContent{
//        _ = self.dataCache.object(forKey: forKey as NSString)!.beginContentAccess();
//        return self.dataCache.object(forKey: forKey as NSString)! as! NSDiscardableContent;
//
//    }
//
//    /// <#Description#>
//    /// use this finished after accessing a NSDiscardableContent object so that
//    /// it can be removed when it's no longer needed.
//    /// - Parameter forKey: object's associated key
//    public func finishDiscardableAccess( forKey: AnyObject){
//         self.dataCache.object(forKey: forKey)!.endContentAccess();
//
//    }
    
//    /// <#Description#>
//    ///tries to safely remove a NSDiscardableContent object.
//    /// - Parameter forKey: object's associated key to be removed.
//    public func enhanceMemory( forKey: AnyObject){
//        let willDiscard:NSDiscardableContent = self.dataCache.object(forKey: forKey) as! NSDiscardableContent;
//
//        willDiscard.discardContentIfPossible();
//    }
//    public func getAlbums() -> Dictionary<String , Dictionary<String , AnyObject>> {
//        var tmp = self.getCache(forKey: CacheHandler.ALBUM_DATA ) as? Dictionary<String, Dictionary<String , AnyObject>>;
//        return tmp!;
//    }
//
//    public func getAnAlbum(documentName : String) -> [String: AnyObject]{
//        var tmp =  self.getAlbums();
//
//        return tmp[documentName]!;
//    }
    //put user's info into cache.
//    public func cacheUserAndFamily(){
//        let user = Auth.auth().currentUser!.uid
//        Util.ShowActivityIndicator(withStatus: "please wait...");
//        DBController.getInstance()
//            .getDocumentFromCollection(
//                collectionName: RegisterDBController.USER_COLLECTION_NAME,
//                documentUID:  user){
//                    (userDocument, error) in
//                    if let userDocument = userDocument, userDocument.exists {
//                        self.setCache(obj: userDocument.data() as AnyObject, forKey: CacheHandler.USER_DATA as AnyObject);
////                        self.cacheFamily();
//                        Util.DismissActivityIndicator();
//                    }else{
//                        print("ERROR LOADING cacheUserAndFam::: ", error as Any);
//                    }
//                }
//    }
    
    //simply get user's info.
    public func getUserInfo(completion: @escaping (_ relation: String?, _ gender: SideMenuTableViewController.Gender?, _ familyIn: DocumentReference?, _ error: Error?) -> () = {_,_,_,_ in}){
        let user = Auth.auth().currentUser!.uid
        Util.ShowActivityIndicator(withStatus: "retrieving user information...");
        DBController.getInstance()
            .getDocumentFromCollection(
                collectionName: RegisterDBController.USER_COLLECTION_NAME,
                documentUID:  user){
                    (userDocument, error) in
                    if let userDocument = userDocument, userDocument.exists {
                        var data : [String:Any] = userDocument.data()!
                        
                        // TO DO !!!
                        // MAKE SURE it is not nill
                        //gil: DONE, TRY NOW?
                        let gender = data[RegisterDBController.USER_DOCUMENT_FIELD_GENDER] as! String
                        
                        let position = data[RegisterDBController.USER_DOCUMENT_FIELD_POSITION] as? String
                        let familyDocRef : DocumentReference = data[RegisterDBController.USER_DOCUMENT_FIELD_FAMILY] as! DocumentReference
                        
                        completion(position, SideMenuTableViewController.Gender(rawValue: gender ), familyDocRef, error);

                        Util.DismissActivityIndicator();
                    }else{
                        print("ERROR LOADING cacheUserAndFam::: ", error as Any);
                    }
        }
    }
    
    public func getAlbumInfo (familyID: DocumentReference, completion: @escaping (_ albums: Dictionary <String, Dictionary<String, Any>>?, _ error: Error?)->() = {_,_ in} ){
        
            Util.ShowActivityIndicator(withStatus: "retrieving album information...")
        DBController.getInstance().getDB().collection(AlbumDBController.ALBUM_COLLECTION_NAME).whereField(AlbumDBController.ALBUM_DOCUMENT_FIELD_FAMILY, isEqualTo: familyID).getDocuments(completion: { (querySnapshot, error) in
//                print("getAlbumInfo : do you get called")
                Util.DismissActivityIndicator()
                            //error handle:
                            if let error = error {
                                print("cacheAlbum Error getting documents: \(error)")
                                
                            } else {
                                
                                var albums : Dictionary <String, Dictionary<String, Any>> = Dictionary <String, Dictionary<String,Any>> ();
                                //loop thru each document, parse them into the required data format:
                                for document in querySnapshot!.documents {
                                    let albumDetails : [String:Any] = document.data();
                                    let albumName :String = albumDetails[AlbumDBController.ALBUM_DOCUMENT_FIELD_NAME] as! String;
                                    let owner:DocumentReference? = (albumDetails[AlbumDBController.ALBUM_DOCUMENT_FIELD_OWNER] as! DocumentReference);
                                    //this is for the setCache:
                                    albums[albumName] = [
                                        AlbumDBController.ALBUM_DOCUMENT_FIELD_CREATED_DATE : albumDetails[AlbumDBController.ALBUM_DOCUMENT_FIELD_CREATED_DATE] as Any,
                                        AlbumDBController.ALBUM_DOCUMENT_FIELD_OWNER : owner?.documentID as Any,
                                        AlbumDBController.ALBUM_DOCUMENT_FIELD_MEDIAS : albumDetails[AlbumDBController.ALBUM_DOCUMENT_FIELD_MEDIAS]!,
                                        AlbumDBController.ALBUM_DOCUMENT_FIELD_THUMBNAIL :albumDetails[AlbumDBController.ALBUM_DOCUMENT_FIELD_THUMBNAIL] as Any,
                                        AlbumDBController.ALBUM_DOCUMENT_FIELD_DESCRIPTION :
                                            albumDetails[AlbumDBController.ALBUM_DOCUMENT_FIELD_DESCRIPTION]!,
                                        AlbumDBController.ALBUM_DOCUMENT_FIELD_THUMBNAIL_EXTENSION :
                                            
                                            albumDetails[AlbumDBController.ALBUM_DOCUMENT_FIELD_THUMBNAIL_EXTENSION] as Any,
                                        AlbumDBController.DOCUMENTID : document.documentID
                                        
                                    ]
                                    
                }
                                completion(albums, error);
            }
        })
            }

    ///gets the user's family info.
    /// - Returns:  completion : the relevant family's details to be retrieved.
    public func getFamilyInfo(completion: @escaping (_ UID: String?, _ Motto: String?, _ Name: String?, _ profileUID: String?, _ profileExtension: String?, _ error: Error?) -> () = {_,_,_,_,_,_ in}){
        //get user Document Ref:
        let user = Auth.auth().currentUser!.uid;
        let userDocRef = DBController.getInstance().getDocumentReference(collectionName: RegisterDBController.USER_COLLECTION_NAME, documentUID: user);
        
        Util.ShowActivityIndicator(withStatus: "retrieving user's family information...");
        //get users related family:
        DBController.getInstance().getDB().collection(RegisterDBController.FAMILY_COLLECTION_NAME).whereField(RegisterDBController.FAMILY_DOCUMENT_FIELD_MEMBERS, arrayContains: userDocRef as Any).getDocuments { (familyQuerySnapshot, error) in
            Util.DismissActivityIndicator()
            if let error = error {
                print("ERROR GET FAM \(error)");
            }
            else{
                for doc in familyQuerySnapshot!.documents{
                    let data = doc.data()
                    let motto = data[RegisterDBController.FAMILY_DOCUMENT_FIELD_MOTTO] as? String
                    let name = data[RegisterDBController.FAMILY_DOCUMENT_FIELD_NAME] as? String
                    let profile = data[RegisterDBController.FAMILY_DOCUMENT_FIELD_PROFILE_PICTURE] as? String
                    let profileExt = data[RegisterDBController.FAMILY_DOCUMENT_FIELD_PROFILE_PICTURE_EXT] as? String
                    
                    completion(doc.documentID, motto, name, profile, profileExt,error);
                }
            }
        }}
    
//        DBController.getInstance().getDocumentFromCollection(collectionName: RegisterDBController.USER_COLLECTION_NAME, documentUID: user) { (userData, error) in
//            if let userData = userData, userData.exists{
//                var familyDocRef:DocumentReference = userData!.data()![RegisterDBController.USER_DOCUMENT_FIELD_FAMILY]
//            }
//
//            familyDocRef.getDocument(completion: { (familyData, error) in
//
//            })
//        }
//        DBController.getInstance()
//            .getDocumentFromCollection(
//                collectionName: RegisterDBController.FAMILY_COLLECTION_NAME,
//                documentUID:  user){
//                    (familyDocument, error) in
//                    if let userDocument = userDocument, userDocument.exists {
//                        var data = userDocument.data()
//                        let gender = data?[RegisterDBController.USER_DOCUMENT_FIELD_GENDER] as! String
//                        let position = data?[RegisterDBController.USER_DOCUMENT_FIELD_POSITION] as! String
//
//                        completion(position, SideMenuTableViewController.Gender(rawValue: gender), error);
//
//                        Util.DismissActivityIndicator();
//                    }else{
//                        print("ERROR LOADING cacheUserAndFam::: ", error as Any);
//                    }
//        }
//    }
    
    
    // **** deprecated : Since Now we don't cahce any more
//    public func cacheUser(){
//        let user = Auth.auth().currentUser!.uid
//        DBController.getInstance()
//            .getDocumentFromCollection(
//                collectionName: RegisterDBController.USER_COLLECTION_NAME,
//                documentUID:  user){
//                    (userDocument, error) in
//                    if let userDocument = userDocument, userDocument.exists {
//                        self.setCache(obj: userDocument.data() as AnyObject, forKey: CacheHandler.USER_DATA as AnyObject);
//                    }else{
//                        print("ERROR LOADING cacheUser::: ", error!);
//                    }
//        }
//
//
//    }
    //get Family info and put it to cache:
    // **** deprecated : Since Now we don't cahce any more
//    public func cacheFamily(){
//        var userData : [String:Any] = self.getCache(forKey: CacheHandler.USER_DATA) as! [String : Any];
//        let familyDocumentReference : DocumentReference = userData[RegisterDBController.USER_DOCUMENT_FIELD_FAMILY] as! DocumentReference;
//        familyDocumentReference.getDocument { (familyDocument, error) in
//            if let familyDocument = familyDocument, familyDocument.exists {
//                self.setCache(obj: familyDocument as AnyObject, forKey: CacheHandler.FAMILY_DATA as AnyObject);
//                self.setCache(obj: familyDocumentReference as AnyObject, forKey: CacheHandler.FAMILY_KEY as AnyObject);
//
//            }else{
//                print("ERROR LOADING cacheFamily::: " , error!);
//            }
//
//        }
//    }
    
    //get all albums related to family and put it to cache:
    // **** deprecated : Since Now we don't cahce any more
//    public func cacheAlbums(){
//        //get user's familyDocumentReference:
//        var userData : [String:Any] = self.getCache(forKey: CacheHandler.USER_DATA) as! [String : Any];
//        let familyDocumentReference : DocumentReference = userData[RegisterDBController.USER_DOCUMENT_FIELD_FAMILY] as! DocumentReference;
//        //once found, get all albums related to family:
//        DBController.getInstance().getDB().collection(AlbumDBController.ALBUM_COLLECTION_NAME).whereField(AlbumDBController.ALBUM_DOCUMENT_FIELD_FAMILY, isEqualTo: familyDocumentReference)
//            .getDocuments() { (querySnapshot, error) in
//                //error handle:
//                if let error = error {
//                    print("cacheAlbum Error getting documents: \(error)")
//
//                } else {
//
//                    var albums : Dictionary <String, Dictionary<String, Any>> = Dictionary <String, Dictionary<String,Any>> ();
//                    //loop thru each document, parse them into the required data format:
//                    for document in querySnapshot!.documents {
//                        let albumName :String = document.data()[AlbumDBController.ALBUM_DOCUMENT_FIELD_NAME] as! String;
//                        let owner:DocumentReference? = (document.data()[AlbumDBController.ALBUM_DOCUMENT_FIELD_OWNER] as! DocumentReference);
//                        albums[albumName] = [
//                            AlbumDBController.ALBUM_DOCUMENT_FIELD_CREATED_DATE : document.data()[AlbumDBController.ALBUM_DOCUMENT_FIELD_CREATED_DATE] as Any,
//                            AlbumDBController.ALBUM_DOCUMENT_FIELD_OWNER : owner?.documentID as Any,
//                            AlbumDBController.ALBUM_DOCUMENT_FIELD_MEDIAS :document.data()[AlbumDBController.ALBUM_DOCUMENT_FIELD_MEDIAS]!,
//                            AlbumDBController.ALBUM_DOCUMENT_FIELD_THUMBNAIL :document.data()[AlbumDBController.ALBUM_DOCUMENT_FIELD_THUMBNAIL] as Any,
//                            AlbumDBController.ALBUM_DOCUMENT_FIELD_DESCRIPTION :
//                                document.data()[AlbumDBController.ALBUM_DOCUMENT_FIELD_DESCRIPTION]!,
//                            AlbumDBController.ALBUM_DOCUMENT_FIELD_THUMBNAIL_EXTENSION :
//
//                                document.data()[AlbumDBController.ALBUM_DOCUMENT_FIELD_THUMBNAIL_EXTENSION] as Any,
//                            AlbumDBController.DOCUMENTID : document.documentID
//
//                        ]
//                    }
//                    CacheHandler.getInstance().setCache(obj: albums as AnyObject, forKey: CacheHandler.ALBUM_DATA as AnyObject);
//                }
//        }
//    }
//    public func startCache(completion: @escaping () -> () = {}){
//        //set familyUID's cache:
//        let user = Auth.auth().currentUser!.uid
//
//        DBController.getInstance()
//            .getDocumentFromCollection(
//                collectionName: RegisterDBController.USER_COLLECTION_NAME,
//                documentUID:  user)
//            {  (userDocument, error) in
//                if let userDocument = userDocument, userDocument.exists {
//                    let familyDocRef:DocumentReference = userDocument.get(RegisterDBController.USER_DOCUMENT_FIELD_FAMILY) as! DocumentReference
//                    familyDocRef.getDocument(completion: { (doc, err) in
//                        CacheHandler.getInstance().setCache(obj: doc?.data() as AnyObject, forKey: CacheHandler.FAMILY_DATA as AnyObject);
//                    })
//
//                    print("Caching in main login:: ");
//                    CacheHandler.getInstance().setCache(obj: familyDocRef, forKey: CacheHandler.FAMILY_KEY as AnyObject);
//
//                    CacheHandler.getInstance().setCache(obj: userDocument.data() as AnyObject, forKey: CacheHandler.USER_DATA as AnyObject);
//                    DBController.getInstance().getDB().collection(AlbumDBController.ALBUM_COLLECTION_NAME).whereField(AlbumDBController.ALBUM_DOCUMENT_FIELD_FAMILY, isEqualTo: familyDocRef)
//                        .getDocuments() { (querySnapshot, err) in
//                            if let err = err {
//                                print("STARTCACHE Error getting documents: \(err)")
//                            } else {
//                                var albums : Dictionary <String, Dictionary<String, Any>> = Dictionary <String, Dictionary<String,Any>> ();
//
//                                for document in querySnapshot!.documents {
//                                    let name :String = document.data()[AlbumDBController.ALBUM_DOCUMENT_FIELD_NAME] as! String;
//                                    let owner:DocumentReference? = (document.data()[AlbumDBController.ALBUM_DOCUMENT_FIELD_OWNER] as! DocumentReference);
//                                    albums[name] = [
//                                        AlbumDBController.ALBUM_DOCUMENT_FIELD_CREATED_DATE : document.data()[AlbumDBController.ALBUM_DOCUMENT_FIELD_CREATED_DATE] as Any,
//                                        AlbumDBController.ALBUM_DOCUMENT_FIELD_OWNER : owner?.documentID as Any,
//                                        AlbumDBController.ALBUM_DOCUMENT_FIELD_MEDIAS :document.data()[AlbumDBController.ALBUM_DOCUMENT_FIELD_MEDIAS]!,
//                                        AlbumDBController.ALBUM_DOCUMENT_FIELD_THUMBNAIL :document.data()[AlbumDBController.ALBUM_DOCUMENT_FIELD_THUMBNAIL] as Any,
//                                                    AlbumDBController.ALBUM_DOCUMENT_FIELD_DESCRIPTION :
//                                                        document.data()[AlbumDBController.ALBUM_DOCUMENT_FIELD_DESCRIPTION]!,
//                                                    AlbumDBController.ALBUM_DOCUMENT_FIELD_THUMBNAIL_EXTENSION :
//
//                                                        document.data()[AlbumDBController.ALBUM_DOCUMENT_FIELD_THUMBNAIL_EXTENSION] as Any,
//                                                    AlbumDBController.DOCUMENTID : document.documentID
//
//                                    ]
//                                }
//                                CacheHandler.getInstance().setCache(obj: albums as AnyObject, forKey: CacheHandler.ALBUM_DATA as AnyObject);
//                            }
//                    }
//                }else{
//                    print("ERROR LOADING main login:: ");
//                }
//
//                // finished cache, maybe you can do something you want
//                completion()
//                Util.DismissActivityIndicator();
//
//        }
//
//    }
    // one album has many media files.
    //so, load their data.
//    public func getPhotos(albumDocRef : DocumentReference ) -> [PhotoDetail]{
//
//        var photos : [PhotoDetail] =  [PhotoDetail] ();
//        //get all photos related to this albbum:
//            DBController.getInstance().getDB().collection(AlbumDBController.MEDIA_COLLECTION_NAME).whereField(AlbumDBController.MEDIA_DOCUMENT_FIELD_ALBUM, isEqualTo: albumDocRef).getDocuments(completion: { (QuerySnapshot, error) in
//
//                if let error = error {
//                    print("error at getPhotos::: " , error);
//                }else{
//                    //for each photo, parse details into PhotoDetail type:
//                    //TODO: comments parse properly bro
//                    for document in QuerySnapshot!.documents{
//                        var data: [String : Any] =  document.data();
//                        photos.append(PhotoDetail(title: document.documentID,
//                                                  description: data[AlbumDBController.MEDIA_DOCUMENT_FIELD_DESCRIPTION] as! String,
//                                                  UID: document.documentID, likes: data[AlbumDBController.MEDIA_DOCUMENT_FIELD_LIKES] as? Int,
//                                                  comments: nil));
//
//
//                    }
//                }
//
//            })
//
//
//
//    }
    
    
    
    
 
    
    

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

extension CacheHandler :  NSCacheDelegate{
    
    func cache(_ cache: NSCache<AnyObject, AnyObject>, willEvictObject obj: Any) {
        // todo : reload cache here if the cache is evit
        print("CacheHandler : this is about to be evict : ")
        print(obj)
    }
    
}
    
    
    

    
    
    


