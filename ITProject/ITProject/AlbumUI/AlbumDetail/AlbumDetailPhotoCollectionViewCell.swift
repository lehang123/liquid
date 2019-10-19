//
//  AlbumDetailPhotoCollectionViewCell.swift
//  ITProject
//
//  Created by Erya Wen on 2019/8/17.
//  Copyright © 2019 liquid. All rights reserved.
//

import UIKit

class AlbumDetailPhotoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var photoImageView: UIImageView!
    
    @IBOutlet var videoPlayImageView: UIImageView!
    var mediaUID: String!
    
    /// album detail photo 
    var image: UIImage! {
        didSet {
            self.photoImageView.image = image
            self.photoImageView.contentMode = .scaleToFill
            self.setNeedsLayout()
        }
        
    }
}

