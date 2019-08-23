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
    
    @IBOutlet private weak var expandLogo: UIImageView!
    
    public func setLogoExpandDown(){
        expandLogo.image = #imageLiteral(resourceName: "expand_down")
    }
    
    public func setLogoExpandUp(){
        expandLogo.image = #imageLiteral(resourceName: "expand_up")
    }
}
