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
    private var title = ""
    private var coverImage: UIImage!
    private var images: [UIImage]
    private var description = ""
    //private var UID = "Util.GenerateUDID()"
    //TEMPTESTING
    private var UID = ""

    
    init(title: String, description: String, images: [UIImage])
    {
        let defaultImage : UIImage = #imageLiteral(resourceName: "item4")
        
        self.title = title
        self.coverImage = images.first ?? defaultImage
        self.description = description
        self.images = images
        
        //TEMPTESTING
        self.UID = title
        
    }
    
    public func getUID() -> String{
        return self.UID
    }
    
    public func getTitle() -> String{
        return self.title
    }
    
    public func getDescription() -> String{
        return self.description
    }
    
    public func getCoverImage() -> UIImage{
        return self.coverImage
    }
    
    public func getImageList() -> [UIImage]{
        return self.images
    }
    
    public func setTitle(title: String){
        self.title = title
    }
    
    public func setDescription(description: String){
        self.description = description
    }
    
    public func setCoverImage(image: UIImage){
        self.coverImage = image
    }
    
    public func setImageList(images: [UIImage]){
        self.images = images
    }
    

    
}
