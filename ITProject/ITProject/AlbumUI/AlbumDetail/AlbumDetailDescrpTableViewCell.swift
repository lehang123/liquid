//
//  AlbumDetailTableViewCell.swift
//  ITProject
//
//  Created by Erya Wen on 2019/8/16.
//  Copyright © 2019 liquid. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import AVKit

protocol AlbumDetailDescrpTableViewCellDedelegate {
    func playDescriptionAudio()
}

///handles displaying Album Title and Description 
class AlbumDetailDescrpTableViewCell: UITableViewCell {

    var delegate:AlbumDetailDescrpTableViewCellDedelegate!
   
    @IBOutlet weak var descpDetail: UILabel!
    @IBOutlet weak var descpTitle: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    
    @IBOutlet weak var playAudioButton: UIButton!{
        didSet{
            self.playAudioButton.imageView!.animationImages = [
                ImageAsset.voice_Image_1.image,
                ImageAsset.voice_Image_1.image,
                ImageAsset.voice_Image_3.image
            ]
            playAudioButton.imageView!.animationDuration = 1
            playAudioButton.isSelected = false
        }
    }
    
    @IBAction func playAudio(_ sender: Any) {
        delegate.playDescriptionAudio()
        
        self.playAudioButton.imageView!.startAnimating()
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

extension AlbumDetailDescrpTableViewCell: AVAudioPlayerDelegate{
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.playAudioButton.imageView!.stopAnimating()
        self.playAudioButton.isSelected = false
    }
}
