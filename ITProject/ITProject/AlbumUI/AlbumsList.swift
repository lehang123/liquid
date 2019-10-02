//
//  AlbumList.swift
//  ITProject
//
//  Created by Erya Wen on 2019/8/16.
//  Copyright © 2019 liquid. All rights reserved.
//

import Foundation
import UIKit

/// Lists each album to UI.
class AlbumsList {
    /// an local album array
    private var currentAlbums: [AlbumDetail] = []
    
    /// get an local alb
    public func fetchAlbumArray() -> [AlbumDetail] {
        return currentAlbums
    }
    
    /// add new album
    /// - Parameter title: album title
    /// - Parameter description: if the album wanted added at first
    /// - Parameter UID: album UID
    /// - Parameter coverImageUID: album cover image UID
    /// - Parameter coverImageExtension: album cover image Extension
    /// - Parameter addToHead: if the album wanted added at first
    public func addNewAlbum(title: String,
                            description: String,
                            UID: String, photos _: [String]?,
                            coverImageUID imageUID: String?,
                            coverImageExtension imageExtension: String?,
                            location : String,
                            addToHead _: Bool = true) {
        let album = AlbumDetail(title: title,
                                description: description,
                                UID: UID,
                                coverImageUID: imageUID,
                                coverImageExtension: imageExtension,
                                location : location)

        addNewAlbum(newAlbum: album, addToHead: true)

    }
    /// add new album
    /// - Parameter newAlbum: album detail information
    /// - Parameter addToHead: if the album wanted added at first
    public func addNewAlbum(newAlbum: AlbumDetail, addToHead: Bool = true) {
        if !currentAlbums.contains(newAlbum) {
            if addToHead {
                currentAlbums.insert(newAlbum, at: 0)
            } else {
                currentAlbums.append(newAlbum)
            }
        }
    }
    
    /// get the index of an album based on the album details information
    /// - Parameter album: album detail information
    public func getIndexForItem(album: AlbumDetail) -> Int {
        return currentAlbums.firstIndex(of: album)!
    }

    /// deletes an album from UI.
    /// - Parameter albumToDelete: album to be deleted
    public func removeAlbum(albumToDelete: AlbumDetail) {
        currentAlbums.remove(at: currentAlbums.firstIndex(of: albumToDelete)!)
    }
    
    /// remove the specific album based on the index
    /// - Parameter at: the index of an album
    public func removeAlbum(at: Int) {
        currentAlbums.remove(at: at)
    }
    
    
    /// get the specific album based on the index
    /// - Parameter index: the index of an album
    public func getAlbum(index: Int) -> AlbumDetail {
        return currentAlbums[index]
    }
    
    
    /// get the number of local album
    public func count() -> Int {
        return currentAlbums.count
    }
}
