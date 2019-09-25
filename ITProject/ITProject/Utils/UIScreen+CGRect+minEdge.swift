//
//  UIScreen + edge.swift
//  ITProject
//
//  Created by Erya Wen on 2019/9/24.
//  Copyright © 2019 liquid. All rights reserved.
//

import Foundation
import UIKit

extension UIScreen {
    var minEdge: CGFloat {
        return UIScreen.main.bounds.minEdge
    }
}

extension CGRect {
    var minEdge: CGFloat {
        return min(width, height)
    }
}
