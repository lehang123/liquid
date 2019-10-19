//
//  AddPhotoCollectionViewCell.swift
//  ITProject
//
//  Created by Gong Lehan on 27/9/19.
//  Copyright © 2019 liquid. All rights reserved.
//

import Foundation
import UIKit

class AddPhotoCollectionViewCell: UICollectionViewCell{
    
    var UID: String!
    @IBOutlet weak var TheImageView: UIImageView!
    @IBOutlet var videoIconImageView: UIImageView!
    

    @IBOutlet var bottomMaskView: UIView!
    
    @IBOutlet var videoLabel: UILabel!
    
    var isPhoto : Bool = true {
        didSet{
            videoIconImageView.isHidden = true
            bottomMaskView.isHidden = true
            videoLabel.isHidden = true
        }
    }
    
    
}
