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

///handles displaying Album Title and Description 
class AlbumDetailDescrpTableViewCell: UITableViewCell {

    
   
    @IBOutlet weak var descpDetail: UILabel!
    @IBOutlet weak var descpTitle: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    
    private var audioPlayer : AVAudioPlayer!
    private var isPlaying = false
    var audioUID:String!
    
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
       
        if(isPlaying)
        {
            audioPlayer.stop()
            isPlaying = false
            self.playAudioButton.imageView!.stopAnimating()
            self.playAudioButton.isSelected = false
            
        }
        else
        {
            playDescriptionAudio()
            self.playAudioButton.imageView!.startAnimating()
          
        }
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
    
    func playDescriptionAudio() {
        let audioUID = self.audioUID
        if audioUID!.removingWhitespaces().isEmpty{
            print("there is no audioUID")
            return
        }
        
        print("playDescriptionAudio : playing audio with UID : " + audioUID!)
        if(isPlaying)
                {
                    audioPlayer.stop()
                    isPlaying = false
                }
                else
                {
                    Util.GetLocalFileURL(by: audioUID!, type: .audio){
                       url in
                       self.prepare_play(url: url!)
                   }
                  
                }
    }

    func prepare_play(url: URL)
    {
        do
        {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer.prepareToPlay()
            audioPlayer.delegate = self
            audioPlayer.play()
            isPlaying = true
        }
        catch{
            print("Error")
        }
    }
    
    

}

extension AlbumDetailDescrpTableViewCell: AVAudioPlayerDelegate{
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.playAudioButton.imageView!.stopAnimating()
        self.playAudioButton.isSelected = false
    }
}
