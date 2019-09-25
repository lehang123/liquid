//
//  AlbumDetailTableViewCell.swift
//  ITProject
//
//  Created by Erya Wen on 2019/8/16.
//  Copyright © 2019 liquid. All rights reserved.
//

import UIKit

class AlbumDetailDescrpTableViewCell: UITableViewCell {

   
    @IBOutlet weak var descpDetail: UILabel!
    @IBOutlet weak var descpTitle: UILabel!
    
    /// reset the album detail if anything changed
    var descrp: AlbumDetail! {
        didSet {
            self.updateUI()
        }
    }
    
    /// update album detail information
    func updateUI()
    {
        descpTitle.text = "Description"
        descpDetail.text = descrp.description
    }

}
