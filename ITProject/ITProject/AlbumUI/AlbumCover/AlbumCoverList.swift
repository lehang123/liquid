//
//  AlbumList.swift
//  ITProject
//
//  Created by Erya Wen on 2019/8/16.
//  Copyright © 2019 liquid. All rights reserved.
//

import Foundation
import UIKit

class AlbumCoverList {
    
    private static var currentAlbum = [
        AlbumCoverDetail(title: "Sydney", featuredImage: UIImage(named: "item0")!),
        AlbumCoverDetail(title: "Cafe with Friends", featuredImage: UIImage(named: "item1")!),
        AlbumCoverDetail(title: "Study Development", featuredImage: UIImage(named: "item2")!),
        AlbumCoverDetail(title: "ChengHong", featuredImage: UIImage(named: "item3")!),
        
        ]
    // dummy data
    public static func fetchAlbumArray() -> [AlbumCoverDetail]
    {
        return currentAlbum
    }
    
    public func addNewAlbum(title newAlbumTitle: String, imageName newAlbumImage : String) {
        AlbumCoverList.currentAlbum.append(AlbumCoverDetail(title: newAlbumTitle, featuredImage: UIImage(named: newAlbumImage)!))
    }
    
}
