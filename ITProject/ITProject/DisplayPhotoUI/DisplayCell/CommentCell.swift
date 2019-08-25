//
//  CommentCell.swift
//  ITProject
//
//  Created by Gong Lehan on 23/8/19.
//  Copyright © 2019 liquid. All rights reserved.
//

import Foundation
import UIKit

class CommentCell: UITableViewCell {
    
    private static let COMMENT_ERROR = "Error reading comment"
    private static let USERNAME_ERROR = "Error reading username"
    
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!

    public func setCommentLabel(comment: String){
        commentLabel.text = comment
    }
    
    public func setUsernameLabel(username: String){
        usernameLabel.text = username
    }
    
    public func getCommentLabel()->String{
        return commentLabel!.text ?? CommentCell.COMMENT_ERROR
    }
    
    public func getUsernameLabel()->String{
        return usernameLabel!.text ?? CommentCell.USERNAME_ERROR
    }
}
