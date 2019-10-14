//
//  AlbumDBController.swift
//  ITProject
//
//  Created by Gilbert Vincenta on 16/8/19.
//  Copyright © 2019 liquid. All rights reserved.
//

import Foundation

import Firebase

/// functions for  creating albums and adding photos into album.
class AlbumDBController
{
	private static var single: AlbumDBController!
	/// constant for ALBUMS collections
	public static let ALBUM_COLLECTION_NAME = "albums"
    /// album's name
	public static let ALBUM_DOCUMENT_FIELD_NAME = "name"
    /// album's description
	public static let ALBUM_DOCUMENT_FIELD_DESCRIPTION = "description"

    /// the families associated in album
	public static let ALBUM_DOCUMENT_FIELD_FAMILY = "family_path"
    /// the owner associated in album
	public static let ALBUM_DOCUMENT_FIELD_OWNER = "owner_path"
    /// the album's created date
	public static let ALBUM_DOCUMENT_FIELD_CREATED_DATE = "date_created"
    /// album's photo thumbnail
	public static let ALBUM_DOCUMENT_FIELD_THUMBNAIL = "thumbnail"
    /// album's photo thumbnail's extension
	public static let ALBUM_DOCUMENT_FIELD_THUMBNAIL_EXTENSION = "thumbnail_extension"
    ///location of album:
    public static let ALBUM_DOCUMENT_FIELD_LOCATION = "location"
    public static let ALBUM_DOCUMENT_FIELD_AUDIO  = "audio"

    

	/* constant for MEDIA collections */
    /// media's collection name
	public static let MEDIA_COLLECTION_NAME = "media"
    /// no. of watches, as an array.
	public static let MEDIA_DOCUMENT_FIELD_WATCH = "watch"
    /// no. of likes, as an array.
	public static let MEDIA_DOCUMENT_FIELD_LIKES = "likes"
    /// comments field, as an array of maps.
	public static let MEDIA_DOCUMENT_FIELD_COMMENTS = "comments"
    /// description field
	public static let MEDIA_DOCUMENT_FIELD_DESCRIPTION = "description"
    /// file extension field
	public static let MEDIA_DOCUMENT_FIELD_EXTENSION = "extension"
    /// the media's created date
	public static let MEDIA_DOCUMENT_FIELD_CREATED_DATE = "date_created"
    /// reference back to album field
	public static let MEDIA_DOCUMENT_FIELD_ALBUM = "album_path"
    ///audio  directory in storage
    public static let MEDIA_DOCUMENT_FIELD_AUDIO = "audio"
   

    /// this refers to the user attribute of the comment.
	public static let COMMENTS_USERNAME = "username"
    /// this refers to the message attribute of the comment.
	public static let COMMENTS_MESSAGE = "message"

	/// doument ID of the album / media:
	public static let DOCUMENTID = "documentID"

	init() {}
    
    /// updates the comment's field of a certain media.
    /// - Parameter username: user that commented
    /// - Parameter comment: comment message
    /// - Parameter photoUID: photo to be commentedPhoto.
	public func UpdateComments(username: DocumentReference, comment: String, commentedPhotoUID: String)
	{
		/* comment structure : [
         * [  "username" : DocumentReference,
         * "message"  : String]
         * ]*/
        
		DBController.getInstance()
			.updateArrayField(
				collectionName: AlbumDBController.MEDIA_COLLECTION_NAME,
				documentUID: commentedPhotoUID,
				fieldName: AlbumDBController.MEDIA_DOCUMENT_FIELD_COMMENTS,
				appendValue: [AlbumDBController.COMMENTS_USERNAME: username, AlbumDBController.COMMENTS_MESSAGE: comment]
			)
	}
    

	/// singleton pattern:
	/// - Returns: return an instance of this AlbumDBController.
	public static func getInstance() -> AlbumDBController
	{
		if self.single == nil
		{
			self.single = AlbumDBController()
		}
		return self.single
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
                    
                    
                    let dateTimestamp : Timestamp = albumDetails[AlbumDBController.ALBUM_DOCUMENT_FIELD_CREATED_DATE] as! Timestamp
                    
                    

                    albums[albumName] = [
                        AlbumDBController.ALBUM_DOCUMENT_FIELD_CREATED_DATE: dateTimestamp.dateValue() as Any,
                        AlbumDBController.ALBUM_DOCUMENT_FIELD_OWNER: owner?.documentID as Any,
                        AlbumDBController.ALBUM_DOCUMENT_FIELD_THUMBNAIL: albumDetails[AlbumDBController.ALBUM_DOCUMENT_FIELD_THUMBNAIL] as Any,
                        AlbumDBController.ALBUM_DOCUMENT_FIELD_DESCRIPTION: albumDetails[AlbumDBController.ALBUM_DOCUMENT_FIELD_DESCRIPTION]!,
                        AlbumDBController.ALBUM_DOCUMENT_FIELD_THUMBNAIL_EXTENSION: albumDetails[AlbumDBController.ALBUM_DOCUMENT_FIELD_THUMBNAIL_EXTENSION] as Any,
                        AlbumDBController.DOCUMENTID: document.documentID,
                        AlbumDBController.ALBUM_DOCUMENT_FIELD_LOCATION : albumDetails[AlbumDBController.ALBUM_DOCUMENT_FIELD_LOCATION] as Any,
                        AlbumDBController.ALBUM_DOCUMENT_FIELD_AUDIO :
                            albumDetails[AlbumDBController.ALBUM_DOCUMENT_FIELD_AUDIO] as Any
                        
                    ]
                    
                }
                
                sortedAlbums = albums.sorted(by: { (first, second) -> Bool in

                    let (_, firstDetail) = first

                    let (_, secondDetail) = second
                    let firstDate: Date = firstDetail[AlbumDBController.ALBUM_DOCUMENT_FIELD_CREATED_DATE] as! Date
                    let secondDate: Date = secondDetail[AlbumDBController.ALBUM_DOCUMENT_FIELD_CREATED_DATE] as! Date
                    
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

    ///  get all Photos from database.
        /// - Parameter currAlbum: get all photos from  curAlbum's
        /// - Parameter completion: completion description
        public func getAllPhotosInfo(currAlbum: String, completion: @escaping (_ allMedias: [MediaDetail], _ error: Error?) -> Void = { _, _ in })
        {
            
            var allMedias: [MediaDetail] = [MediaDetail]()
            let currAlbumRef = DBController.getInstance().getDocumentReference(collectionName: AlbumDBController.ALBUM_COLLECTION_NAME, documentUID: currAlbum)

            print("getting currAlbumRef : " + currAlbumRef.documentID)
           //get all photos from an album:
            DBController
                .getInstance()
                .getDB()
                .collection(AlbumDBController.MEDIA_COLLECTION_NAME)
                .whereField(AlbumDBController.MEDIA_DOCUMENT_FIELD_ALBUM, isEqualTo: currAlbumRef)
                .getDocuments
            { mediaQS, error in
                //handle error:
                if let error = error
                {
                    print("ERROR AT getAllPhotosInfo: ", error)
                }
                    
                else
                {
                    
                    
                    let docs :[QueryDocumentSnapshot] = mediaQS!.documents.sorted { (first, second) -> Bool in
                        let firstData :[String:Any] = first.data()
                        let secondData :[String:Any] = second.data()
                        let firstDate :Timestamp = firstData[AlbumDBController.MEDIA_DOCUMENT_FIELD_CREATED_DATE] as! Timestamp
                        let secondDate :Timestamp = secondData[AlbumDBController.MEDIA_DOCUMENT_FIELD_CREATED_DATE] as! Timestamp
                        switch firstDate.compare(secondDate)
                        {
                            case .orderedAscending:
                                return false
                            case .orderedSame:
                                return true

                            case .orderedDescending:
                                return true
                        }
                    }
                                             
                    for doc in docs
                    {
                        // get current data:
                        let currData: [String: Any] = doc.data()
                        
                        // process comments
                        let currComments: [[String: Any]] = currData[AlbumDBController.MEDIA_DOCUMENT_FIELD_COMMENTS] as? [[String: Any]] ?? [[:]]

                        var parsedComments: [MediaDetail.comment] = [MediaDetail.comment]()
                        //for each comment array, parse them:
                        currComments.forEach
                        { commentRow in
                            parsedComments
                                .append(
                                    MediaDetail
                                        .comment(
                                            commentID: Util.GenerateUDID(),
                                            username: (commentRow[AlbumDBController.COMMENTS_USERNAME] as? DocumentReference ) ?? nil,
                                            message: commentRow[AlbumDBController.COMMENTS_MESSAGE] as? String))
    //                        print("at getAllPhotosInfo::: ", commentRow[AlbumDBController.COMMENTS_USERNAME], commentRow[AlbumDBController.COMMENTS_MESSAGE])
                        }

                        // parse all data:
                        allMedias.append(
                            MediaDetail(title: doc.documentID,
                                        description: currData[AlbumDBController.MEDIA_DOCUMENT_FIELD_DESCRIPTION] as? String,
                                        UID: doc.documentID,
                                        likes: (currData[AlbumDBController.MEDIA_DOCUMENT_FIELD_LIKES] as! [DocumentReference]?)!,
                                        comments: parsedComments,
                                        ext: currData[AlbumDBController.MEDIA_DOCUMENT_FIELD_EXTENSION] as? String,
                                        watch: currData[AlbumDBController.MEDIA_DOCUMENT_FIELD_WATCH] as? [DocumentReference] ?? [],
                                        audioUID : currData[AlbumDBController.MEDIA_DOCUMENT_FIELD_AUDIO] as? String ?? ""))
                       // print("at getAllPhotosInfo::: audioUID:: ", currData[AlbumDBController.MEDIA_DOCUMENT_FIELD_AUDIO])
                    }
                    //print("after getAllPhotosInfo, length is:::", allMedias.count)
                    //pass data thru:
                    completion(allMedias, error)
                }
            }
        }

    /// creates a new album and attaches it to the family .
    /// user may also populate the album with a few media.
    /// all tasks committed as 1 batch.
    /// - Parameters:
    ///   - albumName: name of the album to be added.
    ///   - description: album's short description.
    ///   - completion: gives the album's DocumentReference.
    ///   - thumbnail: album's photo thumbnail.
    ///   - thumbnailExt: photo thumbnail's extension.
    ///   - mediaWithin: all the media related to this album.
	public func addNewAlbum(albumName: String,
                            description: String,
                            thumbnail: String,
                            thumbnailExt: String,
                            mediaWithin : [MediaDetail],
                            location: String,
                            completion:
                            @escaping
                            (_ album: (DocumentReference?),
                            _ error: Error?) -> Void = { _, _ in })
	{
		// get currentUser's family
		let user = Auth.auth().currentUser!.uid
		let userDocumentReference = DBController.getInstance().getDocumentReference(collectionName: RegisterDBController.USER_COLLECTION_NAME, documentUID: user)
		DBController.getInstance()
			.getDocumentFromCollection(
				collectionName: RegisterDBController.USER_COLLECTION_NAME,
				documentUID: user
			)
		{ document, error in
			if let document = document, document.exists
			{
				let familyDocRef: DocumentReference? = document.get(RegisterDBController.USER_DOCUMENT_FIELD_FAMILY) as! DocumentReference?

			

				
                
                //ASSUME: DATE CREATED OF EACH PHOTO IS TODAY.
                
                let batch = DBController.getInstance().getDB().batch()
                
            /* init new album
                     * update: album has reference to family + owner/creator.
                     * update: album has photo thumbnail + date created is stored.
                     * update: now we use batch for potentially
                     *         adding photos directly to album.
                     */
                let albumDocumentReference = DBController.getInstance().getDB().collection(AlbumDBController.ALBUM_COLLECTION_NAME).document()
                
                batch.setData([
                    AlbumDBController.ALBUM_DOCUMENT_FIELD_NAME: albumName,
                    AlbumDBController.ALBUM_DOCUMENT_FIELD_DESCRIPTION: description,
                    AlbumDBController.ALBUM_DOCUMENT_FIELD_FAMILY: familyDocRef!,
                    AlbumDBController.ALBUM_DOCUMENT_FIELD_OWNER: userDocumentReference,
                    AlbumDBController.ALBUM_DOCUMENT_FIELD_THUMBNAIL: thumbnail,
                    AlbumDBController.ALBUM_DOCUMENT_FIELD_CREATED_DATE: Timestamp(date: Date()),
                    AlbumDBController.ALBUM_DOCUMENT_FIELD_THUMBNAIL_EXTENSION: thumbnailExt,
                    AlbumDBController.ALBUM_DOCUMENT_FIELD_LOCATION : location,
                    AlbumDBController.ALBUM_DOCUMENT_FIELD_AUDIO : ""
                ], forDocument: albumDocumentReference)
                
                
                
                /*create new docs for each media included:
                //try to move it down after batch.commit():
                 update: watch,comments,and likes now in arrays!
                 */
                let templateUser = DBController.getInstance().getDocumentReference(collectionName: RegisterDBController.USER_COLLECTION_NAME, documentUID: "NRlhcwr4nR9t17mg27mq")
                
                mediaWithin.forEach { (item) in
                    
                    batch.setData([
                        AlbumDBController.MEDIA_DOCUMENT_FIELD_WATCH: [],
                        AlbumDBController.MEDIA_DOCUMENT_FIELD_LIKES: [],
                        AlbumDBController.MEDIA_DOCUMENT_FIELD_AUDIO : "",
                        AlbumDBController.MEDIA_DOCUMENT_FIELD_COMMENTS:
                            [
                                [
                                    AlbumDBController.COMMENTS_USERNAME: templateUser,
                                    AlbumDBController.COMMENTS_MESSAGE: "This is the comment section"
                                ]
                            ],
                        AlbumDBController.MEDIA_DOCUMENT_FIELD_EXTENSION: item.getExtension(),
                        AlbumDBController.MEDIA_DOCUMENT_FIELD_DESCRIPTION: item.getDescription() ?? "",
                        AlbumDBController.MEDIA_DOCUMENT_FIELD_ALBUM:  albumDocumentReference,
                        AlbumDBController.MEDIA_DOCUMENT_FIELD_CREATED_DATE: Timestamp(date: Date())
                    ], forDocument: DBController.getInstance().getDB().collection(AlbumDBController.MEDIA_COLLECTION_NAME).document(item.getUID()))
                    
                    if item.getExtension().contains(Util.EXTENSION_M4V) ||
                       item.getExtension().contains(Util.EXTENSION_MP4) ||
                       item.getExtension().contains(Util.EXTENSION_MOV){
                        
                        let videoPath = Util.VIDEO_FOLDER + "/" + item.getUID() + "." + Util.EXTENSION_ZIP
                        
                        //print("video path is: ",videoPath)
 
                        //upload video thumbnail:
                        Util.UploadFileToServer(data: item.cache, metadata: nil, fileName: item.getUID(), fextension: Util.EXTENSION_JPEG, completion: {
                            url in

                            //upload video itself:
                            // print("COMPLETION 1")
                           //print("UPLOAD THUMBNAIL SUCCEED")
                            Util.ReadFileFromDocumentDirectory(fileName: videoPath){
                                data in
                                //print("read finish and there is data")
                                Util.UploadZipFileToServer(data: data, metadata: nil, fileName: item.getUID(), fextension: item.getExtension())
                            }
                        })
                        
                        
                    }else {
                        // upload image:
                        Util.UploadFileToServer(data: item.cache, metadata: nil, fileName: item.getUID(), fextension: item.getExtension())
                    }
                    
                }
                
                
                //commit the actions altogether:
                batch.commit() {error  in
                    if let error = error {
                        completion(nil,error)

                    } else {
                        completion(albumDocumentReference,error)
                    }
                }
                

			}
			else
			{
				print("ERROR at addNewAlbum::: ERROR RETRIEVING DOCUMENT: " + error!.localizedDescription)
			}
		}
	}

	/// add/update album photo thumbnail
	/// - Parameter albumUID: add photo thumbnail to this albumUID
	/// - Parameter photoThumbnail: photoThumbnail path to be added
	/// - Parameter photoThumbnailExtension: file extension of photoThumbnail
	public func addAlbumThumbnail(albumUID: String, photoThumbnail: String, photoThumbnailExtension: String)
	{
		DBController
			.getInstance()
			.updateSpecificField(
				newValue: photoThumbnail,
				fieldName: AlbumDBController.ALBUM_DOCUMENT_FIELD_THUMBNAIL,
				documentUID: albumUID,
				collectionName: AlbumDBController.ALBUM_COLLECTION_NAME
			)

		DBController
			.getInstance()
			.updateSpecificField(
				newValue: photoThumbnailExtension,
				fieldName: AlbumDBController.ALBUM_DOCUMENT_FIELD_THUMBNAIL_EXTENSION,
				documentUID: albumUID,
				collectionName: AlbumDBController.ALBUM_COLLECTION_NAME
			)
	}

	public func getAlbums(familyDocumentReference: DocumentReference, completion: @escaping ((QuerySnapshot?, Error?) -> Void))
	{
		DBController
			.getInstance()
			.getDB()
			.collection(AlbumDBController.ALBUM_COLLECTION_NAME)
			.whereField(AlbumDBController.ALBUM_DOCUMENT_FIELD_FAMILY,
			            isEqualTo: familyDocumentReference as Any).getDocuments
		{ querysnapshot, error in
			completion(querysnapshot, error)
		}
	}

	/// adds a media file's path into a "media" collection,
	/// and attaches it into an album.
	/// - Parameters:
	///   - desc: the (short) media file's description
	///   - ext: the file extension (e.g. .zip)
	///   - albumUID: the UID of the album to be updated.
	///   - mediaPath:  the media file's path to be inserted ( unique), preferrably fullPaths.
    public func addPhotoToAlbum(desc: String, ext: String, albumUID: String, mediaPath: String, dateCreated: Timestamp, audioUID:String  )
	{
		/* init new media
		 * update: now has Date Created + reference to its own album
		 * update: Comment is in : Array of [username : value, message : value ]
         * update : like is now an Array of userDocumentReference.
         * update: the watch is now an []. each user can contribute to only 1 watch count.*/
        
		let albumDocRef: DocumentReference = DBController
			.getInstance()
			.getDocumentReference(
				collectionName: AlbumDBController.ALBUM_COLLECTION_NAME,
				documentUID: albumUID
			)

        let templateUser = DBController.getInstance().getDocumentReference(collectionName: RegisterDBController.USER_COLLECTION_NAME, documentUID: "NRlhcwr4nR9t17mg27mq")
		DBController
			.getInstance()
			.addDocumentToCollectionWithUID(
				documentUID: mediaPath,
				inputData: [
					AlbumDBController.MEDIA_DOCUMENT_FIELD_WATCH: [],
                    AlbumDBController.MEDIA_DOCUMENT_FIELD_AUDIO : audioUID,
					AlbumDBController.MEDIA_DOCUMENT_FIELD_LIKES: [],
					 AlbumDBController.MEDIA_DOCUMENT_FIELD_COMMENTS:
                                               [
                                                   [
                                                       AlbumDBController.COMMENTS_USERNAME: templateUser,
                                                       AlbumDBController.COMMENTS_MESSAGE: "This is the comment section"
                                                   ]
                                               ],
					AlbumDBController.MEDIA_DOCUMENT_FIELD_EXTENSION: ext,
					AlbumDBController.MEDIA_DOCUMENT_FIELD_DESCRIPTION: desc,
					AlbumDBController.MEDIA_DOCUMENT_FIELD_ALBUM: albumDocRef,
					AlbumDBController.MEDIA_DOCUMENT_FIELD_CREATED_DATE: dateCreated
				],
				collectionName: AlbumDBController.MEDIA_COLLECTION_NAME
			)

		
	}


                    
                    

	/// gets all album listeners for certain user's family.
	/// useful for getting notified for updates / deletions / additions to albums.
	/// - Parameter familyDocumentReference: user's family
	public func addAlbumSnapshotListener(familyDocumentReference: DocumentReference)
	{
		DBController
			.getInstance()
			.getDB()
			.collection(AlbumDBController.ALBUM_COLLECTION_NAME)
			.whereField(AlbumDBController.ALBUM_DOCUMENT_FIELD_FAMILY,
			            isEqualTo: familyDocumentReference as Any)
			.addSnapshotListener
		{ querySnapshot, error in
			guard let snapshot = querySnapshot else
			{
				print("addAlbumSnapshotListener::: Error fetching snapshots: \(error!)")
				return
			}
			snapshot.documentChanges
				.forEach
			{ diff in
				if diff.type == .added
				{
					print("addAlbumSnapshotListener::: New photos added: \(diff.document.data())")
				}
				if diff.type == .modified
				{
					print(" addAlbumSnapshotListener ::: Modified photos: \(diff.document.data())")
				}
				if diff.type == .removed
				{
					print("addAlbumSnapshotListener::: Removed photos: \(diff.document.data())")
				}
			}
		}
	}

	/// remove a media from album in database (as well as storage).
	/// - Parameters:
	///   - mediaPath: media's file path to be removed form album.
	///   - albumUID: the albumUID that the media belongs to.
    //todo: change to using batch()
    public func deleteMediaFromAlbum(mediaPath: String, albumUID: String, ext : String)
	{
		// get all photos attached to this album:


		// remove photo file from storage
		
        Util.DeleteFileFromServer(fileName: mediaPath, fextension: ext)
        //todo remove video /audios!!!
		

		// delete media document from media collection:
		DBController.getInstance()
			.deleteWholeDocumentfromCollection(
				documentUID: mediaPath,
				collectionName: AlbumDBController.MEDIA_COLLECTION_NAME
			)
	}

	/// completely delete a whole album including its media files and thumbnail.
	/// - Parameters:
	///   - albumUID: album's UID to be deleted.
    //todo: change to using batch()
    public func deleteAlbum(albumUID: String)
    {
        
        let albumDocumentReference: DocumentReference = DBController.getInstance().getDocumentReference(collectionName: AlbumDBController.ALBUM_COLLECTION_NAME, documentUID: albumUID)
        // get all media files:
        DBController
            .getInstance()
            .getDB()
            .collection(AlbumDBController.MEDIA_COLLECTION_NAME)
            .whereField(AlbumDBController.MEDIA_DOCUMENT_FIELD_ALBUM,
                        isEqualTo: albumDocumentReference as Any)
            .getDocuments
        { querySnapshot, _ in
            querySnapshot?
                .documents
                //then, for each file::
                .forEach
            { doc in
                //delete from storage:
                Util.DeleteFileFromServer(
                            fileName: doc.documentID,
                            fextension: doc.data()[AlbumDBController.MEDIA_DOCUMENT_FIELD_EXTENSION] as! String);
                //todo remove video /audios associated!!!

                // delete from db:
                DBController.getInstance().deleteWholeDocumentfromCollection(documentUID: doc.documentID, collectionName: AlbumDBController.MEDIA_COLLECTION_NAME)
                print("deelted photo: \(doc.data())")
            }
            // delete album thumbnail from storage, if there's any:
            DBController.getInstance().getDocumentFromCollection(collectionName: AlbumDBController.ALBUM_COLLECTION_NAME, documentUID: albumUID, completion: { document, _ in

                if document!.data()?[AlbumDBController.ALBUM_DOCUMENT_FIELD_THUMBNAIL] != nil
                {
                    print("deleting thumbnail..")

                    Util.DeleteFileFromServer(fileName: document!.data()![AlbumDBController.ALBUM_DOCUMENT_FIELD_THUMBNAIL] as! String,
                                              fextension: document!.data()![AlbumDBController.ALBUM_DOCUMENT_FIELD_THUMBNAIL_EXTENSION] as! String)
                }

            })
            // delete album from db:
            DBController.getInstance().deleteWholeDocumentfromCollection(documentUID: albumUID, collectionName: AlbumDBController.ALBUM_COLLECTION_NAME)
        }

        
    }
}
