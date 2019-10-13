//
//  DescriptionCell.swift
//  ITProject
//
//  Created by 陳信宏保佑🙏 on 2019/9/25.
//  Copyright © 2019 liquid. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import AVKit

class DescriptionCell: UITableViewCell{
    
    private static let COMMENT_ERROR = "Error reading comment"
    private static let USERNAME_ERROR = "Error reading username"
    private var audioUID : String!
    private var audioPlayer : AVAudioPlayer!
    
    @IBOutlet weak var descriptionDetail: UILabel!
    
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
    
    public func setDescriptionLabel(description: String){
        if (description.isEmpty) {

            descriptionDetail.text = "Click to add description..."

        } else {
            descriptionDetail.text = description
        }
    }

    
    public func setAudioUID(audioUID:String){

        self.audioUID = audioUID
    }
        

    
    @IBAction func onClickPlayAudio(_ sender: Any) {
        if(audioPlayer?.isPlaying ?? false)
        {
            audioPlayer.stop()
            self.playAudioButton.imageView!.stopAnimating()
            self.playAudioButton.isSelected = false
            
        }
        else
        {
            playDescriptionAudio()
            self.playAudioButton.imageView!.startAnimating()
          
        }
               
           }
    
        func playDescriptionAudio() {
            
             if self.audioUID.removingWhitespaces().isEmpty{
                 print("there is no audioUID")
                 return
             }
            
             if(audioPlayer?.isPlaying ?? false)
                 {
                     audioPlayer.stop()
                 }
                 else
                 {
                     Util.GetLocalFileURL(by: self.audioUID, type: .audio){
                        url in
                         let newURL = URL(fileURLWithPath: url!.absoluteString)
                         print("URL prepare_play", newURL)
                          
                         self.prepare_play(url: newURL)
                    }
                   
                 }
        }
           
       func prepare_play(url: URL)
       {
           do
           {
               
               audioPlayer = try AVAudioPlayer(contentsOf: url)
               audioPlayer.delegate = self
               audioPlayer.prepareToPlay()
               audioPlayer.play()
               self.playAudioButton.imageView!.startAnimating()
           }
           catch{
               print("Error")
           }
       }
    
    public func getDescriptionDLabel()->String{
        return descriptionDetail!.text ?? DescriptionCell.COMMENT_ERROR
    }
    
}

extension DescriptionCell: AVAudioPlayerDelegate{
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.playAudioButton.imageView!.stopAnimating()
        self.playAudioButton.isSelected = false
    }
}

