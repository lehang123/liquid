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

    
    private var currentAlbums:[AlbumCoverDetail] = []

    // dummy data
    public func fetchAlbumArray() -> [AlbumCoverDetail]
    {
        return currentAlbums
    }
    
    public func addNewAlbum(title newAlbumTitle: String, imageName newAlbumImage : String) {
        currentAlbums.append(AlbumCoverDetail(title: newAlbumTitle, featuredImage: UIImage(named: newAlbumImage)!))
    }
    
    public func addNewAlbum(title newAlbumTitle: String, data imageData : Data){
        if !currentAlbums.contains(AlbumCoverDetail(title: newAlbumTitle, featuredImage: UIImage(data: imageData)!)){
            currentAlbums.append(AlbumCoverDetail(title: newAlbumTitle, featuredImage: UIImage(data: imageData)!))
        }
    }
    
    public  func removeAlbum(albumToDelete: AlbumCoverDetail) {
        currentAlbums.remove(at: currentAlbums.firstIndex(of: albumToDelete)!)
    }
    
    public func getAlbum(index : Int)->AlbumCoverDetail{
        return currentAlbums[index]
    }
    
    public func count()->Int{
        return currentAlbums.count
    }
}
