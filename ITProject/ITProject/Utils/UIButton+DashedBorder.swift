//
//  UIButton+DashedBorder.swift
//  ITProject
//
//  Created by Erya Wen on 2019/9/13.
//  Copyright © 2019 liquid. All rights reserved.
//

import Foundation
import UIKit

extension UIButton
{
	func createDashedLine(bound: CGRect, color: UIColor, strokeLength: NSNumber, gapLength: NSNumber, width: CGFloat)
	{
		let pathlayer = CAShapeLayer()
		let bounds = bound
		pathlayer.path = UIBezierPath(roundedRect: bounds, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: 10, height: 10)).cgPath
		pathlayer.strokeColor = color.cgColor
		pathlayer.fillColor = UIColor.clear.cgColor
		pathlayer.lineDashPattern = [strokeLength, gapLength]
		pathlayer.lineWidth = width
		layer.addSublayer(pathlayer)
	}
}
