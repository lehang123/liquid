//
//  CarouselEffectCollectionViewCell.swift
//  ITProject
//
//  Created by Erya Wen on 2019/8/12.
//  Copyright © 2019 liquid. All rights reserved.
//

import UIKit

class CarouselEffectCollectionViewCell: UICollectionViewCell
{
    // MARK: - Constants and Properties
	@IBOutlet var iconImage: UIImageView!
	@IBOutlet var labelInf: UILabel!

    static let identifier = "CarouselCollectionViewCell"
    
    // MARK: - Initialize
    /// initial the collection view cell with carousel effect
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

		layer.cornerRadius = 10.0
	}
}
