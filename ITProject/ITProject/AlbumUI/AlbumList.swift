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

    
    private var currentAlbums:[AlbumDetail] = []
    
    lazy private var tempImages :[UIImage] = makeRandomList()
    
    func makeRandomList () -> [UIImage]{
        var item1Images = [UIImage]()
        for i in (1...4).map( {_ in Int.random(in: 0...4)} ) {
            print("ASdfasdfas", i)
            item1Images.append(UIImage(named: "item\(i)")!)
        }
        
        return item1Images
        
    }
    

    
    public func fetchAlbumArray() -> [AlbumDetail]
    {
        return currentAlbums
    }
    
    public func addNewAlbum(title newAlbumTitle: String, description newAlbumDescrp: String, UID: String){
//            if !currentAlbums.contains(AlbumDetail(title: newAlbumTitle, description: newAlbumDescrp, images : newImagesList)){
//                currentAlbums.append(AlbumDetail(title: newAlbumTitle, description: newAlbumDescrp, images : newImagesList))
//            }
        if !currentAlbums.contains(AlbumDetail(title: newAlbumTitle, description: newAlbumDescrp, UID:"")){
            currentAlbums.append(AlbumDetail(title: newAlbumTitle, description: newAlbumDescrp, UID: UID))
        }
    }
    
    
//    public func addNewAlbum(title newAlbumTitle: String, imageName newAlbumImage : String) {
//        currentAlbums.append(AlbumDetail(title: newAlbumTitle, featuredImage: UIImage(named: newAlbumImage)!))
//    }
//
//    public func addNewAlbum(title newAlbumTitle: String, data imageData : Data){
//        if !currentAlbums.contains(AlbumDetail(title: newAlbumTitle, featuredImage: UIImage(data: imageData)!)){
//            currentAlbums.append(AlbumDetail(title: newAlbumTitle, featuredImage: UIImage(data: imageData)!))
//        }
//    }
    
    
    
    public  func removeAlbum(albumToDelete: AlbumDetail) {
        currentAlbums.remove(at: currentAlbums.firstIndex(of: albumToDelete)!)
    }
    
    public func getAlbum(index : Int)->AlbumDetail{
        return currentAlbums[index]
    }
    
    public func count()->Int{
        return currentAlbums.count
    }
}
