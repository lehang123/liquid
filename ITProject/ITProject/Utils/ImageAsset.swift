//
//  ImageAsset.swift
//  ITProject
//
//  Created by Erya Wen on 2019/10/7.
//  Copyright © 2019 liquid. All rights reserved.
//

typealias ImageAsset = UIImage.Asset

import Foundation
import UIKit

extension UIImage {
    enum Asset : String {
        case able_send_icon = "ableSendIcon"
        case add_icon = "addIcon"
        case add_photo_button = "addPhotoButton"
        case album_icon = "albumIcon"
        case bookmark_icon = "bookmark"
        case expand_down_icon = "expand_down"
        case expand_up_icon = "expand_up"
        case eye_icon = "eye"
        case default_image = "defaultImage"
        case description_icon = "descriptionIcon"
        case disable_send_icon = "disableSendIcon"
        case edit_name_icon = "editNameIcon"
        case heart_icon = "heartIcon"
        case home_icon = "homeIcon"
        case image_icon = "imageIcon"
        case keyboard_view_icon = "keyboardViewIcon"
        case logout_icon = "logoutIcon"
        case menu_icon = "menuIcon"
        case message_icon = "messageIcon"
        case mic_icon = "micIcon"
        case pause_icon = "pauseIcon"
        case play_icon = "playIcon"
        case recording_Signal_1 = "recordingSignal1"
        case recording_Signal_2 = "recordingSignal2"
        case recording_Signal_3 = "recordingSignal3"
        case recording_Signal_4 = "recordingSignal4"
        case recording_Signal_5 = "recordingSignal5"
        case recording_Signal_6 = "recordingSignal6"
        case recording_Signal_7 = "recordingSignal7"
        case recording_Signal_8 = "recordingSignal8"
        case record_playing_1 = "recordPlaying1"
        case record_playing_2 = "recordPlaying2"
        case record_playing_3 = "recordPlaying3"
        case setting_icon = "settingIcon"
        case timeline_icon = "timelineIcon"
        case upload_icon = "uploadIcon"
        case voice_Image_1 = "voiceImage1"
        case voice_Image_2 = "voiceImage2"
        case voice_Image_3 = "voiceImage3"
        case voice_input_icon = "voiceInputIcon"
        

        
        var image: UIImage {
            return UIImage(asset: self)
        }
    }
    
    convenience init!(asset: Asset) {
        self.init(named: asset.rawValue)
    }
}






