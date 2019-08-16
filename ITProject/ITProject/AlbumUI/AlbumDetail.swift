//
//  AlbumList.swift
//  ITProject
//
//  Created by Erya Wen on 2019/8/15.
//  Copyright © 2019 liquid. All rights reserved.
//

import Foundation

import UIKit

class AlbumDetail
{
    // MARK: - Public API
    var title = ""
    var featuredImage: UIImage
    
    init(title: String, featuredImage: UIImage)
    {
        self.title = title
        self.featuredImage = featuredImage
    }
    
    // MARK: - Private
    // dummy data
    static func fetchAlbumArray() -> [AlbumDetail]
    {
        return [
            AlbumDetail(title: "Sydney", featuredImage: UIImage(named: "item0")!),
            AlbumDetail(title: "Cafe with Friends", featuredImage: UIImage(named: "item1")!),
            AlbumDetail(title: "Study Development", featuredImage: UIImage(named: "item2")!),
            AlbumDetail(title: "ChengHong", featuredImage: UIImage(named: "item3")!),
            
        ]
    }
}
