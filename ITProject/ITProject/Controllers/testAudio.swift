//
//  testAudioVC.swift
//  ITProject
//
//  Created by 陳信宏保佑🙏 on 2019/9/27.
//  Copyright © 2019 liquid. All rights reserved.
//

import UIKit
import Foundation
import AVFoundation


class testAudio: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    
    @IBOutlet weak var recordTimeLabel: UILabel!
    @IBOutlet weak var record_btn_ref: UIButton!
    @IBOutlet weak var play_btn_ref: UIButton!
    
    var audioRecorder: AVAudioRecorder!
    var isAudioRecordingGranted: Bool!
    var isRecording = false
    var audioPlayer : AVAudioPlayer!
    var isPlaying = false
    var meterTimer:Timer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.check_record_permission()
    }
    
    func check_record_permission()
    {
        switch AVAudioSession.sharedInstance().recordPermission {
        case AVAudioSessionRecordPermission.granted:
            isAudioRecordingGranted = true
            print ("allowed")
            break
        case AVAudioSessionRecordPermission.denied:
            isAudioRecordingGranted = false
            print ("not allowed")
            break
        case AVAudioSessionRecordPermission.undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission({ (allowed) in
                if allowed {
                    self.isAudioRecordingGranted = true
                    print ("allowed")
                } else {
                    self.isAudioRecordingGranted = false
                    print ("not allowed")
                }
            })
            break
        default:
            break
        }
    }
    
    func setup_recorder()
    {
        if isAudioRecordingGranted
        {
            let session = AVAudioSession.sharedInstance()
            do
            {
                try session.setCategory(AVAudioSession.Category.playAndRecord)
                //try session.setCategory(AVAudioSessionCategoryPlayAndRecord, with: .defaultToSpeaker)
                try session.setActive(true)
                let settings = [
                    AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                    AVSampleRateKey: 44100,
                    AVNumberOfChannelsKey: 2,
                    AVEncoderAudioQualityKey:AVAudioQuality.high.rawValue
                ]
                audioRecorder = try AVAudioRecorder(url: getFileUrl(), settings: settings)
                audioRecorder.delegate = self
                audioRecorder.isMeteringEnabled = true
                audioRecorder.prepareToRecord()
            }
            catch let error {
                            Util.ShowAlert(title: "Error", message: error.localizedDescription, action_title: "OK", on: self)
            }
        }
        else
        {
            Util.ShowAlert(title: "Error", message: "Don't have access to use your microphone.", action_title: "OK", on: self)

        }
    }
    
    @IBAction func start_recording(_ sender: Any) {
        if(isRecording)
        {
            finishAudioRecording(success: true)
            record_btn_ref.setTitle("Record", for: .normal)
            play_btn_ref.isEnabled = true
            isRecording = false
        }
        else
        {
            setup_recorder()
            
            audioRecorder.record()
            meterTimer = Timer.scheduledTimer(timeInterval: 0.1, target:self, selector:#selector(self.updateAudioMeter(timer:)), userInfo:nil, repeats:true)
            record_btn_ref.setTitle("Stop", for: .normal)
            play_btn_ref.isEnabled = false
            isRecording = true
        }
    }
    
    @objc func updateAudioMeter(timer: Timer)
    {
        if audioRecorder.isRecording
        {
            let hr = Int((audioRecorder.currentTime / 60) / 60)
            let min = Int(audioRecorder.currentTime / 60)
            let sec = Int(audioRecorder.currentTime.truncatingRemainder(dividingBy: 60))
            let totalTimeString = String(format: "%02d:%02d:%02d", hr, min, sec)
            recordTimeLabel.text = totalTimeString
            audioRecorder.updateMeters()
        }
    }
    
    func finishAudioRecording(success: Bool)
    {
        if success
        {
            audioRecorder.stop()
            audioRecorder = nil
            meterTimer.invalidate()
            print("recorded successfully.")
        }
        else
        {
            Util.ShowAlert(title: "Error", message: "Recording failed.", action_title: "OK", on: self)
        }
    }
    
    @IBAction func play_recording(_ sender: Any) {
        if(isPlaying)
        {
            audioPlayer.stop()
            record_btn_ref.isEnabled = true
            play_btn_ref.setTitle("Play", for: .normal)
            isPlaying = false
        }
        else
        {
            if FileManager.default.fileExists(atPath: getFileUrl().path)
            {
                record_btn_ref.isEnabled = false
                play_btn_ref.setTitle("pause", for: .normal)
                prepare_play()
                audioPlayer.play()
                isPlaying = true
            }
            else
            {
                Util.ShowAlert(title: "Error", message: "Audio file is missing.", action_title: "OK", on: self)
            }
        }

    }
    
    func prepare_play()
    {
        do
        {
            audioPlayer = try AVAudioPlayer(contentsOf: getFileUrl())
            audioPlayer.delegate = self
            audioPlayer.prepareToPlay()
        }
        catch{
            print("Error")
        }
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool)
    {
        if !flag
        {
            finishAudioRecording(success: false)
        }
        play_btn_ref.isEnabled = true
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool)
    {
        record_btn_ref.isEnabled = true
    }
    
    func getDocumentsDirectory() -> URL
    {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    func getFileUrl() -> URL
    {
//        let filename = "myRecording.m4a"
//        let filePath = getDocumentsDirectory().appendingPathComponent(filename)
        let filePath = NSURL(fileURLWithPath: "/Users/zhuchenghong/Desktop/TESTING1.m4a")
        return filePath as URL
    }
    
    
    
}
