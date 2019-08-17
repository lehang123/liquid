//
//  TempAlbumDetail.swift
//  ITProject
//
//  Created by Erya Wen on 2019/8/16.
//  Copyright © 2019 liquid. All rights reserved.
//

import Foundation
import UIKit

class TempAlbumDetail
{
    var name: String?
    var images: [UIImage]?
    var description: String?

    
    init(name: String, images: [UIImage], description: String)
    {
        self.name = name
        self.images = images
        self.description = description
    }
    
    class func fetchPhoto() -> [TempAlbumDetail]
    {
        var albumd = [TempAlbumDetail]()
        
        // 1
        var item1Images = [UIImage]()
        for i in [0,1,2,3] {
            item1Images.append(UIImage(named: "item\(i)")!)
        }
        let item0 = TempAlbumDetail(name: "Sydney", images: item1Images, description: "1Established in 1853, the University of Melbourne is a public-spirited institution that makes distinctive contributions to society in research.")
        albumd.append(item0)
        
        // 2
        var item2Images = [UIImage]()
        for i in [1,2,3,4]{
            item2Images.append(UIImage(named: "item\(i)")!)
        }
        let item2 = TempAlbumDetail(name: "Cafe with Friends", images: item2Images, description: "2Established in 1853, the University of Melbourne is a public-spirited institution that makes distinctive contributions to society in research.")
        albumd.append(item2)
        
        
        // 3
        var item3Images = [UIImage]()
        for i in [2,3,4,0] {
            item3Images.append(UIImage(named: "item\(i)")!)
        }
        let item3 = TempAlbumDetail(name: "Study Development", images: item3Images, description: "3Established in 1853, the University of Melbourne is a public-spirited institution that makes distinctive contributions to society in research.")
        albumd.append(item3)
        
        // 4
        var item4Images = [UIImage]()
        for i in [3,4,0,1] {
            item4Images.append(UIImage(named: "item\(i)")!)
        }
        let item4 = TempAlbumDetail(name: "ChengHong", images: item4Images, description: "4Established in 1853, the University of Melbourne is a public-spirited institution that makes distinctive contributions to society in research.")
        albumd.append(item4)
        
        return albumd
    }
}

























