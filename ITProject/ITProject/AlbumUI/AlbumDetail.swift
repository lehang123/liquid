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
    
    /* title of ablum */
    private var title = ""
    
    public func getTitle() -> String{
        return self.title
    }
    
    public func setTitle(title: String){
        self.title = title
    }
    
    /* coverImage of ablum */
    private var coverImage: UIImage!
    
    public func getCoverImage() -> UIImage{
        return self.coverImage
    }
    
    public func setCoverImage(image: UIImage){
        self.coverImage = image
    }
    
    /* description of ablum */
    private var description = ""
    
    public func getDescription() -> String{
        return self.description
    }
    
    public func setDescription(description: String){
        self.description = description
    }
    
    
    /* UID of ablum */
    
    private var UID = ""
    
    public func getUID() -> String{
        return self.UID
    }
    
    /* photos that contained in the album */
    private var photos = [PhotoDetail]()
    
    public func getPhotos()->[PhotoDetail]{
        return photos
    }

    public func addPhoto(photo : PhotoDetail){
        photos.append(photo)
    }

    public func removePhoto(photo : PhotoDetail){
        photos = photos.filter{$0 != photo}
    }
    
    init(title: String, description: String, UID : String, photos : [PhotoDetail], coverImage : UIImage?)
    {
        let defaultImage : UIImage = #imageLiteral(resourceName: "item4")
        
        self.title = title
        self.coverImage = coverImage ?? defaultImage
        self.description = description
        self.UID = UID
        self.photos = photos
    }
    
}
