//
//  ExpandDownCell.swift
//  ITProject
//
//  Created by Gong Lehan on 23/8/19.
//  Copyright © 2019 liquid. All rights reserved.
//

import Foundation
import UIKit

class ExpandCell: UITableViewCell {
    
    private static let READING_ERROR = "Error reading expand logo"
    var cellState = Work.Expand
    enum Work {
        case Expand
        case Collapse
    }
    @IBOutlet private weak var expandLogo: UIImageView!
    
    public func setLogoExpand(){
        cellState = Work.Expand
        expandLogo.image = #imageLiteral(resourceName: "expand_down")
    }
    
    public func setLogoCollapse(){
        cellState = Work.Collapse
        expandLogo.image = #imageLiteral(resourceName: "expand_up")
    }
    
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//
//    }
}
