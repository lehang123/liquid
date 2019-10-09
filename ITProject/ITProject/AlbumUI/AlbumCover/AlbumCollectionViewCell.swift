//
//  AlbumCollectionViewCell.swift
//  ITProject
//
//  Created by Erya Wen on 2019/8/15.
//  Copyright © 2019 liquid. All rights reserved.
//

import UIKit
import SwipeCellKit

class AlbumCollectionViewCell: SwipeCollectionViewCell {
    
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var albumTitleLabel: UILabel!
    @IBOutlet weak var backgroundMask: UIView!
    
    /// reset the album detail if anything changed
    var album: AlbumDetail? {
        didSet {
            self.updateUI()
        }
    }
    
    /// update album detail information
    private func updateUI()
    {
         self.setupAlbumLayout()
        if let album = album {
            
            Util.GetImageData(imageUID: album.coverImageUID,
                              UIDExtension: album.coverImageExtension, completion: {
                                data in
                                self.backgroundImageView.image = UIImage(data: data!)
                                self.albumTitleLabel.text = album.title
                                
                                let format = DateFormatter()
                                       format.dateFormat = "dd.MM.yyyy"
                                       let formattedDate = format.string(from: album.createDate)
                                self.dateLabel.text = formattedDate
                            
                                
                    
            })
            
        } else {
            backgroundImageView.image = nil
            albumTitleLabel.text = nil
            backgroundMask.backgroundColor = nil
            dateLabel.text = nil
        }
    }
     
    /// set up album layout in albumCollectionView
    private func setupAlbumLayout(){
        
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
    }
    
    @objc func deleteSelf() {
        print("custom revealView delete")
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
