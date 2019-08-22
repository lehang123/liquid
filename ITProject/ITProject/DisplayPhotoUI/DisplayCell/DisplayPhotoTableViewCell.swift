//
//  DisplayPhotoTableViewCell.swift
//  ITProject
//
//  Created by Gong Lehan on 22/8/19.
//  Copyright © 2019 liquid. All rights reserved.
//

import UIKit

class DisplayPhotoTableViewCell: UITableViewCell {

    @IBOutlet weak var displayPhotoImageView: UIImageView!
    
    var displayImage: UIImage! {
        didSet {
            self.displayPhotoImageView.image = displayImage
            self.setNeedsLayout()
        }
        
    }

}
