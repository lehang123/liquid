//
//  MeidaDetail.swift
//  ITProject
//
//  Created by Gong Lehan on 6/9/19.
//  Copyright © 2019 liquid. All rights reserved.
//

import Foundation

import UIKit
import Firebase

/// Manages each photo's attributes and interactions for the UI.
class MediaDetail: Equatable
{
	public struct comment: Equatable
	{
		let commentID: String!
		let username: String!
		let message: String!

		static func == (lhs: comment, rhs: comment) -> Bool
		{
			return lhs.commentID == rhs.commentID
		}
	}

	/* filename :  UID.zip or UID.jpg */
	public let UID: String!
	public let ext: String!
	private var watch: [DocumentReference]?

	public func getUID() -> String
	{
		return self.UID
	}
    
    public func getExtension() -> String
    {
        return self.ext
    }
	/// photo's title
	private var title: String!

	public func getTitle() -> String
	{
		return self.title
	}

	public func changeTitle(to: String!)
	{
		self.title = to
	}

	/// photo's description
	private var description: String!

	public func getDescription() -> String!
	{
		return self.description
	}

	public func changeDescription(to: String!)
	{
		self.description = to
	}

	/// photo's   likes as a array of who has liked this photo:
	private var likes: [DocumentReference]?
    
    /// Get number of likes for this photo:
	public func getLikesCounter() -> Int!
	{
        return self.likes?.count
	}
    
    public func getLikesData() -> [DocumentReference]?
    {
        return self.likes
    }
    public func hasLiked() -> Bool{
        //get self current user:
        let currentUserReference = DBController.getInstance().getDocumentReference(collectionName: RegisterDBController.USER_COLLECTION_NAME, documentUID: Auth.auth().currentUser!.uid)
        return (self.likes?.contains(currentUserReference))!;
    }

	/// add likes counter and update it to db too.
	public func upLikes()
	{
        //get self current user:
        let currentUserReference = DBController.getInstance().getDocumentReference(collectionName: RegisterDBController.USER_COLLECTION_NAME, documentUID: Auth.auth().currentUser!.uid)
        //update to db:
        DBController.getInstance().updateArrayField(collectionName: AlbumDBController.MEDIA_COLLECTION_NAME, documentUID: self.UID, fieldName: AlbumDBController.MEDIA_DOCUMENT_FIELD_LIKES, appendValue: currentUserReference)
        //update to curr array:
        if (self.likes != nil && !(self.likes?.contains(currentUserReference))!){
            self.likes!.append(currentUserReference)
        }
	}

    ///  reduce # of likes by 1
	public func DownLikes()
	{ //get self current user:
           let currentUserReference = DBController.getInstance().getDocumentReference(collectionName: RegisterDBController.USER_COLLECTION_NAME, documentUID: Auth.auth().currentUser!.uid)
        //get curr user index in array:
        
        //remove from DB:
        DBController.getInstance().removeArrayField(collectionName: AlbumDBController.MEDIA_COLLECTION_NAME, documentUID: self.UID, fieldName: AlbumDBController.MEDIA_DOCUMENT_FIELD_LIKES, removeValue: currentUserReference)
        
        //remove in UI list:
        if (self.likes != nil && (self.likes?.contains(currentUserReference))!){
            let idx : Int = self.likes!.firstIndex(of: currentUserReference)!
            self.likes!.remove(at: idx)
        }
	}
    
    var cache: Data!
    
    var audioUID: String!
    var audioExt: String!
    var thumbnailUID:String!
    var thumbnailExt:String!

	/// media's comment
	private var comments: [comment]!

	public func getComments() -> [comment]!
	{
		return self.comments
	}

	public func getWatch() -> Int
	{
        return self.watch?.count ?? 0
	}

	public func addComments(comment: comment)
	{
		self.comments.append(comment)
	}

	public func deleteComments(comment: comment)
	{
		self.comments = self.comments.filter { $0 != comment }
	}

	static func == (lhs: MediaDetail, rhs: MediaDetail) -> Bool
	{
		return lhs.UID == rhs.UID
	}

	init(title: String!, description: String!,
         UID: String!, likes: [DocumentReference],
         comments: [comment]!,
         ext: String!,
         watch: [DocumentReference]?,
         audioUID: String)
	{
		self.UID = UID
		self.title = title
		self.description = description
		self.likes = likes
		self.comments = comments
		self.ext = ext
		self.watch = watch
        self.audioUID = audioUID
	}
    func hasWatch(){
        //get current user:
           let currentUserReference = DBController
            .getInstance()
            .getDocumentReference(
                collectionName: RegisterDBController.USER_COLLECTION_NAME,
                documentUID: Auth.auth().currentUser!.uid)
        
        //if user never seen it yet, then add to watch array:
        if (!(self.watch?.contains(currentUserReference) ?? false)){
            self.watch?.append(currentUserReference);
            DBController
                .getInstance()
                .updateArrayField(
                    collectionName: AlbumDBController.MEDIA_COLLECTION_NAME,
                    documentUID: self.UID,
                    fieldName: AlbumDBController.MEDIA_DOCUMENT_FIELD_WATCH,
                    appendValue: currentUserReference)
        }
        
    }
    
    
    
    func validExtension()->Bool{
        
        switch self.ext {
        case Util.EXTENSION_M4A:
            return true
        case Util.EXTENSION_M4V:
            return true
        case Util.EXTENSION_MP4:
            return true
        case Util.EXTENSION_PNG:
            return true
        case Util.EXTENSION_JPEG:
            return true
        case Util.EXTENSION_ZIP:
            return true
        default:
            return false
        }
    }
    
    public func testValidId()->Bool{
        return self.UID.count == Util.GenerateUDID()?.count
    }
}
