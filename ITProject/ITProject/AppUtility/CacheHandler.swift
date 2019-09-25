//
//  CacheHandler.swift
//  ITProject
//
//  Created by Gilbert Vincenta on 19/8/19.
//  Copyright © 2019 liquid. All rights reserved.
//

import Firebase
import FirebaseCore
import FirebaseFirestore
import Foundation
import UIKit

/// Handles caching data for the app.
class CacheHandler: NSObject
{
	private var dataCache: NSCache<NSString, NSData>

	private static var single: CacheHandler!
	override init()
	{
		self.dataCache = NSCache<NSString, NSData>()
		super.init()
	}

	/// singleton pattern implemented
	/// - Returns: return an instance of this CacheHandler.
	public static func getInstance() -> CacheHandler
	{
		if self.single == nil
		{
			self.single = CacheHandler()
		}
		return self.single
	}

	/// stores an object into NSCache's dictionary.
	/// note that if you set object into same key again,
	/// it'll replace the existing object with the new "obj". (i.e. update instead of create).
	/// - Parameters:
	///   - obj: object to be stored
	///   - forKey: key of the object
	public func setCache(obj: Data, forKey: String)
	{
		self.dataCache.setObject(obj as NSData, forKey: forKey as NSString)
		//        CacheHandler.addCacheCounter()
		print("setCache::: caching : \(obj) with key : \(forKey) succeeded.")
	}

	/// gets an object from cache by its key.
	/// - Parameter forKey: key of the object
	/// - Returns: the object associated with the key given
	public func getCache(forKey: String) -> Data?
	{
		if let data = self.dataCache.object(forKey: forKey as NSString)
		{
			return data as Data
		}
		else
		{
			return nil
		}
	}

	/// removes all objects in cache. be mindful of this when working with others,
	/// as the cache is apparently in singleton manner.
	public func cleanCache()
	{
		self.dataCache.removeAllObjects()
	}

	/// removes 1 object with associated key.
	/// - Parameter forKey: key of the object to be removed.
	public func removeFromCache(forKey: String)
	{
		self.dataCache.removeObject(forKey: forKey as NSString)
	}

	/// get  current user's info from database.
	///  - Parameter completion: passes on relation in family, user's gender, user's family reference.
	public func getUserInfo(completion: @escaping (_ relation: String?, _ gender: Gender?, _ familyIn: DocumentReference?, _ error: Error?) -> Void = { _, _, _, _ in })
	{
		let user = Auth.auth().currentUser!.uid
		Util.ShowActivityIndicator(withStatus: "retrieving user information...")
		DBController.getInstance()
			.getDocumentFromCollection(
				collectionName: RegisterDBController.USER_COLLECTION_NAME,
				documentUID: user
			)
		{
			userDocument, error in
			if let userDocument = userDocument, userDocument.exists
			{
				var data: [String: Any] = userDocument.data()!

				let gender = data[RegisterDBController.USER_DOCUMENT_FIELD_GENDER] as? String

				let position = data[RegisterDBController.USER_DOCUMENT_FIELD_POSITION] as? String
				let familyDocRef: DocumentReference = data[RegisterDBController.USER_DOCUMENT_FIELD_FAMILY] as! DocumentReference

				completion(position, Gender(rawValue: gender ?? "Unknown"), familyDocRef, error)

				Util.DismissActivityIndicator()
			}
			else
			{
				print("ERROR LOADING cacheUserAndFam::: ", error as Any)
			}
		}
	}

	///  get all album's info from database.
	/// - Parameter familyID: album related to the familyID to be retrieved.
	/// - Parameter completion:  passes all albums' info from DB .
	public func getAlbumInfo(familyID: DocumentReference, completion: @escaping (_ albums: [(key: String, value: [String: Any])], _ error: Error?) -> Void = { _, _ in })
	{
		Util.ShowActivityIndicator(withStatus: "retrieving album information...")
		DBController.getInstance().getDB().collection(AlbumDBController.ALBUM_COLLECTION_NAME).whereField(AlbumDBController.ALBUM_DOCUMENT_FIELD_FAMILY, isEqualTo: familyID).getDocuments(completion: { querySnapshot, error in
			//                print("getAlbumInfo : do you get called")
			Util.DismissActivityIndicator()
			// error handle:
			if let error = error
			{
				print("cacheAlbum Error getting documents: \(error)")
			}
			else
			{
				var albums: [String: [String: Any]] = [String: [String: Any]]()
				var sortedAlbums: [(key: String, value: [String: Any])] = [(key: String, value: [String: Any])]()

				// loop thru each document, parse them into the required data format:
				for document in querySnapshot!.documents
				{
					let albumDetails: [String: Any] = document.data()

					let albumName: String = albumDetails[AlbumDBController.ALBUM_DOCUMENT_FIELD_NAME] as! String

					let owner: DocumentReference? = (albumDetails[AlbumDBController.ALBUM_DOCUMENT_FIELD_OWNER] as! DocumentReference)

					albums[albumName] = [
						AlbumDBController.ALBUM_DOCUMENT_FIELD_CREATED_DATE: albumDetails[AlbumDBController.ALBUM_DOCUMENT_FIELD_CREATED_DATE] as Any,
						AlbumDBController.ALBUM_DOCUMENT_FIELD_OWNER: owner?.documentID as Any,
						AlbumDBController.ALBUM_DOCUMENT_FIELD_MEDIAS: albumDetails[AlbumDBController.ALBUM_DOCUMENT_FIELD_MEDIAS] as Any,
						AlbumDBController.ALBUM_DOCUMENT_FIELD_THUMBNAIL: albumDetails[AlbumDBController.ALBUM_DOCUMENT_FIELD_THUMBNAIL] as Any,
						AlbumDBController.ALBUM_DOCUMENT_FIELD_DESCRIPTION: albumDetails[AlbumDBController.ALBUM_DOCUMENT_FIELD_DESCRIPTION]!,
						AlbumDBController.ALBUM_DOCUMENT_FIELD_THUMBNAIL_EXTENSION: albumDetails[AlbumDBController.ALBUM_DOCUMENT_FIELD_THUMBNAIL_EXTENSION] as Any,
						AlbumDBController.DOCUMENTID: document.documentID,
					]
				}

				sortedAlbums = albums.sorted(by: { (first, second) -> Bool in

					let (_, firstDetail) = first

					let (_, secondDetail) = second
					let firstDate: Timestamp = firstDetail[AlbumDBController.ALBUM_DOCUMENT_FIELD_CREATED_DATE] as! Timestamp
					let secondDate: Timestamp = secondDetail[AlbumDBController.ALBUM_DOCUMENT_FIELD_CREATED_DATE] as! Timestamp
					switch firstDate.compare(secondDate)
					{
						case .orderedAscending:
							return false
						case .orderedSame:
							return true

						case .orderedDescending:
							return true
					}

				})
				completion(sortedAlbums, error)
			}
		})
	}

	/// <#Description#> get all Photos from database.
	/// - Parameter currAlbum: get all photos from  curAlbum's
	/// - Parameter completion: completion description
	public func getAllPhotosInfo(currAlbum: String, completion: @escaping (_ allMedias: [PhotoDetail], _ error: Error?) -> Void = { _, _ in })
	{
        
		var allMedias: [PhotoDetail] = [PhotoDetail]()
		let currAlbumRef = DBController.getInstance().getDocumentReference(collectionName: AlbumDBController.ALBUM_COLLECTION_NAME, documentUID: currAlbum)

		print("getting currAlbumRef : " + currAlbumRef.documentID)
       //get all photos from an album:
        DBController.getInstance().getDB().collection(AlbumDBController.MEDIA_COLLECTION_NAME).whereField(AlbumDBController.MEDIA_DOCUMENT_FIELD_ALBUM, isEqualTo: currAlbumRef).getDocuments
		{ mediaQS, error in
            //handle error:
			if let error = error
			{
				print("ERROR AT getAllPhotosInfo: ", error)
			}
                
			else
			{
				print(mediaQS!.documents)
				for doc in mediaQS!.documents
				{
					// get current data:
					let currData: [String: Any] = doc.data()

					// process comments
					let currComments: [[String: Any]] = currData[AlbumDBController.MEDIA_DOCUMENT_FIELD_COMMENTS] as! [[String: Any]]

					var parsedComments: [PhotoDetail.comment] = [PhotoDetail.comment]()
                    //for each comment array, parse them:
					currComments.forEach
					{ commentRow in
						parsedComments.append(PhotoDetail.comment(commentID: Util.GenerateUDID(), username: commentRow[AlbumDBController.COMMENTS_USERNAME] as? String, message: commentRow[AlbumDBController.COMMENTS_MESSAGE] as? String))
						print("at getAllPhotosInfo::: ", commentRow[AlbumDBController.COMMENTS_USERNAME], commentRow[AlbumDBController.COMMENTS_MESSAGE])
					}

					// parse all data:
                    allMedias.append(PhotoDetail(title: doc.documentID, description: currData[AlbumDBController.MEDIA_DOCUMENT_FIELD_DESCRIPTION] as? String, UID: doc.documentID, likes: (currData[AlbumDBController.MEDIA_DOCUMENT_FIELD_LIKES] as! [DocumentReference]?)!, comments: parsedComments, ext: currData[AlbumDBController.MEDIA_DOCUMENT_FIELD_EXTENSION] as? String, watch: currData[AlbumDBController.MEDIA_DOCUMENT_FIELD_WATCH] as! Int))
				}
                //pass data thru:
				completion(allMedias, error)
			}
		}
	}

	/// gets the user's family info.
	/// - Returns:  completion : the relevant family's details to be retrieved.
	public func getFamilyInfo(completion: @escaping (_ UID: String?, _ Motto: String?, _ Name: String?, _ profileUID: String?, _ profileExtension: String?, _ error: Error?) -> Void = { _, _, _, _, _, _ in })
	{
		// get user Document Ref:
		let user = Auth.auth().currentUser!.uid

		print("getting family info with uid : " + user)
		let userDocRef = DBController.getInstance().getDocumentReference(collectionName: RegisterDBController.USER_COLLECTION_NAME, documentUID: user)
		print("getting family info with userDocRef : " + userDocRef.documentID)

		Util.ShowActivityIndicator(withStatus: "retrieving user's family information...")
		// get users related family:
		// question ? : why FAMILY_DOCUMENT_FIELD_MEMBERS
		DBController.getInstance().getDB().collection(RegisterDBController.FAMILY_COLLECTION_NAME).whereField(RegisterDBController.FAMILY_DOCUMENT_FIELD_MEMBERS, arrayContains: userDocRef as Any).getDocuments
		{ familyQuerySnapshot, error in
			Util.DismissActivityIndicator()
			if let error = error
			{
				print("ERROR GET FAM \(error)")
			}
			else
			{
				print("come to here with userDocRef : ")
				for doc in familyQuerySnapshot!.documents
				{
					print("come to here with userDocRef : with the doc")
					let data = doc.data()
					let motto = data[RegisterDBController.FAMILY_DOCUMENT_FIELD_MOTTO] as? String
					let name = data[RegisterDBController.FAMILY_DOCUMENT_FIELD_NAME] as? String
					let profile = data[RegisterDBController.FAMILY_DOCUMENT_FIELD_THUMBNAIL] as? String
					let profileExt = data[RegisterDBController.FAMILY_DOCUMENT_FIELD_THUMBNAIL_EXT] as? String

					completion(doc.documentID, motto, name, profile, profileExt, error)
				}
			}
		}
	}
}
