//
//  CommentCell.swift
//  ITProject
//
//  Created by Gong Lehan on 23/8/19.
//  Copyright © 2019 liquid. All rights reserved.
//

import Foundation
import UIKit
import EnhancedCircleImageView

class CommentCell: UITableViewCell {
    
    // MARK: - Constants and Properties
    private static let COMMENT_ERROR = "Error reading comment"
    private static let USERNAME_ERROR = "Error reading username"
    

    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet var userProfileImage: EnhancedCircleImageView!
    
    // MARK: - Methods
    
    /// set comment deatil
    /// - Parameter comment: comment
    public func setCommentLabel(comment: String){
        commentLabel.text = comment
    }
    
    /// set username detail
    /// - Parameter username: username
    public func setUsernameLabel(username: String){
        usernameLabel.text = username
    }
    
    /// get comment detail
    public func getCommentLabel()->String{
        return commentLabel!.text ?? CommentCell.COMMENT_ERROR
    }
    
    /// get username detail
    public func getUsernameLabel()->String{
        return usernameLabel!.text ?? CommentCell.USERNAME_ERROR
    }
    

}
