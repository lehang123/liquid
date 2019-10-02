//
//  AlbumList.swift
//  ITProject
//
//  Created by Erya Wen on 2019/8/15.
//  Copyright © 2019 liquid. All rights reserved.
//

import Foundation

import UIKit

class AlbumDetail: Equatable
{
	static func == (lhs: AlbumDetail, rhs: AlbumDetail) -> Bool
	{
		return lhs.UID == rhs.UID
	}

	// MARK: - Public API

	/* coverImage of ablum */
	//    private var coverImage: UIImage!
	//
	//    public func getCoverImage() -> UIImage{
	//        return self.coverImage
	//    }
	//
	//    public func setCoverImage(image: UIImage){
	//        self.coverImage = image
	//    }

	/// title of ablum
	var title = ""

	/// coverImage extension for ablum
	var coverImageExtension: String!

	/// coverImage of album
	var coverImageUID: String!

	/// description of album
	var description = ""
    
    /// location of album created
    private(set) var location = ""

	/// UID of album ,private on set
	private(set) var UID = ""

	/// album created date
	private var createDate: Date!
    

	/* photos that contained in the album */
	//    private(set) var photos = [PhotoDetail]()
//
	//    public func addPhoto(photo : PhotoDetail){
	//        photos.append(photo)
	//    }
//
	//    public func removePhoto(photo : PhotoDetail){
	//        photos = photos.filter{$0 != photo}
	//    }


	/// init Album's info. for the UI to display.
	/// - Parameter title: title of the album.
	/// - Parameter description: description of the album/
	/// - Parameter UID: UID of the album itself.
	/// - Parameter imageUID: the thumbnail of album.
	/// - Parameter imageExtension: thumbnail extension  for the album.
    init(title: String, description: String, UID: String, coverImageUID imageUID: String?, coverImageExtension imageExtension: String?, createdLocation location: String = "")
	{
		self.title = title
		self.coverImageUID = imageUID
		self.coverImageExtension = imageExtension
		self.description = description
		self.UID = UID
        self.location = location
	}
}
