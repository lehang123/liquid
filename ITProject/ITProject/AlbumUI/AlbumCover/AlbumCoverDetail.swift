//
//  AlbumList.swift
//  ITProject
//
//  Created by Erya Wen on 2019/8/15.
//  Copyright © 2019 liquid. All rights reserved.
//

import Foundation

import UIKit

class AlbumCoverDetail: Equatable
{
    static func == (lhs: AlbumCoverDetail, rhs: AlbumCoverDetail) -> Bool {
        return lhs.UID == rhs.UID
    }
    
    // MARK: - Public API
    private var title = ""
    private var featuredImage: UIImage
    private var UID = "Util.GenerateUDID()"
    
    init(title: String, featuredImage: UIImage)
    {
        self.title = title
        self.featuredImage = featuredImage
    }
    
    public func getUID()->String{
        return self.UID
    }
    
    public func getFeatureImage()->UIImage{
        return self.featuredImage
    }
    
    public func getTitle()->String{
        return self.title
    }
    
    public func setFeatureImage(image: UIImage){
        self.featuredImage = image
    }
    
    public func setTitle(title: String){
        self.title = title
    }
    
}
