//
//  CarouselEffectCollectionViewCell.swift
//  ITProject
//
//  Created by Erya Wen on 2019/8/9.
//  Copyright © 2019 liquid. All rights reserved.
//

import UIKit

class CarouselEffectCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var labelInf: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.mainView.layer.cornerRadius = 1.0
        self.mainView.layer.shadowColor = UIColor.selfcGrey.cgColor
        self.mainView.layer.shadowOpacity = 0.5
        self.mainView.layer.shadowOffset = CGSize(width: 5, height: 1)
        self.mainView.layer.shadowPath = UIBezierPath(rect: self.mainView.bounds).cgPath
        self.mainView.layer.shouldRasterize = true
        
        
    }

}



