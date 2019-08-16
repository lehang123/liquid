//
//  AlbumCollectionViewCell.swift
//  ITProject
//
//  Created by Erya Wen on 2019/8/15.
//  Copyright © 2019 liquid. All rights reserved.
//

import UIKit

class AlbumCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var albumTitleLabel: UILabel!
    @IBOutlet weak var backgroundMask: UIView!
    
    var album: AlbumDetail? {
        didSet {
            self.updateUI()
        }
    }
    
    private func updateUI()
    {
        if let album = album {
            backgroundImageView.image = album.featuredImage
            albumTitleLabel.text = album.title
            
            
            backgroundMask.layer.cornerRadius = 15.0
            backgroundMask.layer.masksToBounds = true
            backgroundImageView.layer.cornerRadius = 15.0
            backgroundImageView.layer.masksToBounds = true
        } else {
            backgroundImageView.image = nil
            albumTitleLabel.text = nil
            backgroundMask.backgroundColor = nil
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.layer.cornerRadius = 3.0
        layer.shadowRadius = 10
        layer.shadowOpacity = 0.2
        layer.shadowOffset = CGSize(width: 5, height: 10)
        
        self.clipsToBounds = false
    }
}
