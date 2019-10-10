//
//  AlbumDetailTableViewCell.swift
//  ITProject
//
//  Created by Erya Wen on 2019/8/16.
//  Copyright © 2019 liquid. All rights reserved.
//

import UIKit

protocol AlbumDetailDescrpTableViewCellDedelegate {
    func playDescriptionAudio()
}

///handles displaying Album Title and Description 
class AlbumDetailDescrpTableViewCell: UITableViewCell {

    var delegate:AlbumDetailDescrpTableViewCellDedelegate!
   
    @IBOutlet weak var descpDetail: UILabel!
    @IBOutlet weak var descpTitle: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    
    @IBOutlet weak var PlayAudioButton: UIButton!
    
    @IBAction func playAudio(_ sender: Any) {
        delegate.playDescriptionAudio()
    }
    
    /// reset the album detail if anything changed
    var descrp: AlbumDetail! {
        didSet {
            self.updateUI()
        }
    }
    
    /// update album detail information
    func updateUI()
    {
        descpTitle.text = "Description: "
        descpDetail.text = descrp.description
        locationLabel.text = descrp.location
    }

}
