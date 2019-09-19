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
    static func == (lhs: AlbumDetail, rhs: AlbumDetail) -> Bool {
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
    
    
    /* title of ablum */
    var title = ""
    
    /* coverImage extension for ablum */
    var coverImageExtension: String!
    
    /* coverImage of ablum */
    var coverImageUID: String!
    
    /* description of ablum */
    var description = ""
    
    /* UID of ablum ,private on set*/
    private(set) var UID = ""
    
    /* alubm created date */
    private var createDate: Date!
    
    /* photos that contained in the album */
    private(set) var photos = [PhotoDetail]()
    
//    public func getPhotos()->[PhotoDetail]{
//        return photos
//    }

    public func addPhoto(photo : PhotoDetail){
        photos.append(photo)
        //TODO : REPLACE EXTENSION_JPEG WITH THE EXTENSION FROM PHOTO DETAIL
    }

    public func removePhoto(photo : PhotoDetail){
        photos = photos.filter{$0 != photo}
    }
    
//    init(title: String, description: String, UID : String, photos : [PhotoDetail]?, coverImage : UIImage?)
//    {
//        let defaultImage : UIImage = #imageLiteral(resourceName: "item4")
//
//        self.title = title
//        self.coverImage = coverImage ?? defaultImage
//        self.description = description
//        self.UID = UID
//        self.photos = photos ?? []
//    }
    
    init(title: String, description: String, UID : String, photos : [PhotoDetail]?, coverImageUID imageUID : String?, coverImageExtension imageExtension : String?)
    {
        
        self.title = title
        self.coverImageUID = imageUID
        self.coverImageExtension = imageExtension
        self.description = description
        self.UID = UID
        self.photos = photos ?? []
    }
    
}
