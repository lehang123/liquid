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
    var descrp: TempAlbumDetail! {
        didSet {
            self.updateUI()
        }
    }
    
    func updateUI()
    {
        descpTitle.text = "Description"
        descpDetail.text = descrp.description
    }

}
