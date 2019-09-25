//
//  DescriptionCell.swift
//  ITProject
//
//  Created by 陳信宏保佑🙏 on 2019/9/25.
//  Copyright © 2019 liquid. All rights reserved.
//

import Foundation
import UIKit

class DescriptionCell: UITableViewCell {
    
    private static let COMMENT_ERROR = "Error reading comment"
    private static let USERNAME_ERROR = "Error reading username"
    

    @IBOutlet weak var decriptionDetail: UILabel!
    
    public func setDescriptionLabel(decription: String){
        decriptionDetail.text = decription
    }
    
    public func getDescriptionDLabel()->String{
        return decriptionDetail!.text ?? DescriptionCell.COMMENT_ERROR
    }
    
}

