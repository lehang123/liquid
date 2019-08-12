//
//  CarouselEffectCollectionViewCell.swift
//  ITProject
//
//  Created by Erya Wen on 2019/8/12.
//  Copyright © 2019 liquid. All rights reserved.
//

import UIKit

class CarouselEffectCollectionViewCell: UICollectionViewCell {
    //@IBOutlet weak var mainView: UIView!
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var labelInf: UILabel!
    

    static let identifier = "CarouselCollectionViewCell"
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.layer.cornerRadius = 10.0
    }

}
