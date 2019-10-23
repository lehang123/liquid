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
	private(set) var createDate: Date!
    
    /// album audio descrption
    private(set) var audioUID: String!
    



	/// init Album's info. for the UI to display.
	/// - Parameter title: title of the album.
	/// - Parameter description: description of the album/
	/// - Parameter UID: UID of the album itself.
	/// - Parameter imageUID: the thumbnail of album.
	/// - Parameter imageExtension: thumbnail extension  for the album.
    init(title: String,
         description: String,
         UID: String,
         coverImageUID imageUID: String?,
         coverImageExtension imageExtension: String?,
         createdLocation location: String = "",
         createDate: Date,
         audio audioUID: String = "")
	{
		self.title = title
		self.coverImageUID = imageUID
		self.coverImageExtension = imageExtension
		self.description = description
		self.UID = UID
        self.location = location
        self.audioUID = audioUID
        self.createDate = createDate
	}
    
    public func testValidId()->Bool{
        return self.UID.count == Util.GenerateUDID()?.count
    }
    
}
