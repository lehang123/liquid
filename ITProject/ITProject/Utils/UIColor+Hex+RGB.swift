//
//  UIColor+EKColor.swift
//  ITProject
//
//  Created by Erya Wen on 2019/8/23.
//  Copyright © 2019 liquid. All rights reserved.
//

import UIKit

extension UIColor
{

    // Create a UIColor from RGB
    convenience init(red: Int, green: Int, blue: Int)
    {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")

        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }

    // Create a UIColor from a hex value (E.g 0x000000)
    convenience init(rgb: Int)
    {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }

    // MARK: - Useful UIColor
    static let pinky = UIColor(rgb: 0xE91E63)
    static let amber = UIColor(rgb: 0xFFC107)
    static let satCyan = UIColor(rgb: 0x00BCD4)
    static let redish = UIColor(rgb: 0xFF5252)
    static let greenGrass = UIColor(rgb: 0x4CAF50)
    static let selfcGrey = UIColor(rgb: 0x958984)
    static let selfcOrg = UIColor(rgb: 0xD9A674)

}


