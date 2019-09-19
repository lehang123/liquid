//
//  AlbumCollectionViewCell.swift
//  ITProject
//
//  Created by Erya Wen on 2019/8/15.
//  Copyright © 2019 liquid. All rights reserved.
//

import UIKit

class AlbumCollectionViewCell: PZSwipedCollectionViewCell {
    
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
         self.createAlbumLayout()
        if let album = album {
            
            Util.GetImageData(imageUID: album.coverImageUID,
                              UIDExtension: album.coverImageExtension, completion: {
                                data in
                                self.backgroundImageView.image = UIImage(data: data!)
                                self.albumTitleLabel.text = album.title
//                                self.createAlbumLayout()
                    
            })
            
        } else {
            backgroundImageView.image = nil
            albumTitleLabel.text = nil
            backgroundMask.backgroundColor = nil
        }
    }
    
    private func createAlbumLayout(){
        
        
        backgroundMask.layer.cornerRadius = 15.0
        backgroundMask.layer.masksToBounds = true
        backgroundImageView.layer.cornerRadius = 15.0
        backgroundImageView.layer.masksToBounds = true
        
        
        // Define the delete Button for swiping
        let deleteButton = UIButton(frame: CGRect(x: self.bounds.height - 55, y: 0, width: 100, height: self.bounds.height))
        deleteButton.backgroundColor = UIColor.init(red: 255/255.0, green: 58/255.0, blue: 58/255.0, alpha: 1)
        deleteButton.setTitle("delete", for: .normal)
        deleteButton.setTitleColor(UIColor.white, for: .normal)
        deleteButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        
        deleteButton.layer.cornerRadius = 15.0
        deleteButton.layer.masksToBounds = true
        
        deleteButton.addTarget(self, action: #selector(deleteSelf), for: .touchUpInside)
        self.revealView = deleteButton
    }
    
    @objc func deleteSelf() {
        self.hideRevealView(withAnimated: true)
        print("custom revealView delete")
        
        if removeAlbumDelegate != nil {
            removeAlbumDelegate.removeAlbum(albumToDelete: self.albumDetail)
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
