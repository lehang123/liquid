//
//  CALayer+borderColor.swift
//  ITProject
//
//  Created by Erya Wen on 2019/10/15.
//  Copyright © 2019 liquid. All rights reserved.
//

import Foundation
import UIKit

extension CALayer {

    func addBorder(edge: UIRectEdge, adjust: CGFloat, color: UIColor, thickness: CGFloat) {

        let border = CALayer()

        switch edge {
        case UIRectEdge.top:
            
            border.frame = CGRect(x: 0, y: 0, width: self.frame.height + adjust, height: thickness)
            break
        case UIRectEdge.bottom:
            border.frame = CGRect(x: 0, y: self.frame.height - thickness, width: self.frame.width + adjust, height: thickness)
            break
        case UIRectEdge.left:
            border.frame = CGRect(x: 0, y: 0, width: thickness, height: self.frame.height + adjust)
            break
        case UIRectEdge.right:
            border.frame = CGRect(x: self.frame.width - thickness, y: 0, width: thickness, height: self.frame.height + adjust)
            break
        default:
            break
        }

        border.backgroundColor = color.cgColor;

        self.addSublayer(border)
    }

}
