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
    

    @IBOutlet weak var descriptionDetail: UILabel!
    
    @IBOutlet weak var playAudioButton: UIButton!
    public func setDescriptionLabel(description: String){
        if (description.isEmpty) {
            descriptionDetail.text = "No description yest"
        } else {
            descriptionDetail.text = description
        }
    }
    
    public func getDescriptionDLabel()->String{
        return descriptionDetail!.text ?? DescriptionCell.COMMENT_ERROR
    }
    
}

