//
//  AlbumList.swift
//  ITProject
//
//  Created by Erya Wen on 2019/8/16.
//  Copyright © 2019 liquid. All rights reserved.
//

import Foundation
import UIKit

class AlbumList {
    
    private static var currentAlbum = [
        AlbumDetail(title: "Sydney", featuredImage: UIImage(named: "item0")!),
        AlbumDetail(title: "Cafe with Friends", featuredImage: UIImage(named: "item1")!),
        AlbumDetail(title: "Study Development", featuredImage: UIImage(named: "item2")!),
        AlbumDetail(title: "ChengHong", featuredImage: UIImage(named: "item3")!),
        
        ]
    // dummy data
    public static func fetchAlbumArray() -> [AlbumDetail]
    {
        return currentAlbum
    }
    
    public func addNewAlbum(title newAlbumTitle: String, imageName newAlbumImage : String) {
        AlbumList.currentAlbum.append(AlbumDetail(title: newAlbumTitle, featuredImage: UIImage(named: newAlbumImage)!))
    }
    
}
