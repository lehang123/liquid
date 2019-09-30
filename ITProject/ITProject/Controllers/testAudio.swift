//
//  testAudioVC.swift
//  ITProject
//
//  Created by 陳信宏保佑🙏 on 2019/9/27.
//  Copyright © 2019 liquid. All rights reserved.
//

//import Foundation
//import UIKit
//import SwiftEntryKit
//import AVFoundation
//
//class testAudioVC: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
//
//
//    @IBOutlet weak var record: UIButton!
//    @IBOutlet weak var play: UIButton!
//    var soundRecorder: AVAudioRecorder!
//    var soundPlayer:AVAudioPlayer!
//    let fileName = "demo.caf"
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        // Setting up for audio
//        setupRecorder()
//    }
//
//    func getDocumentsDirectory() -> URL {
//        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
//        return paths[0]
//    }
//
////    func getFileURL() -> NSURL {
////        //let path = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
////        let path = getDocumentsDirectory().appendingPathComponent(fileName)
////        let filePath = NSURL(fileURLWithPath: path)
////        return filePath
////    }
//
//    func preparePlayer() {
//        var error: NSError?
//
//        do {
//            soundPlayer = try AVAudioPlayer(contentsOf: getDocumentsDirectory().appendingPathComponent(fileName))
//        } catch let error1 as NSError {
//            error = error1
//            soundPlayer = nil
//        }
//
//        if let err = error {
//            print("AVAudioPlayer error: \(err.localizedDescription)")
//        } else {
//            print ("prepareTopay")
//            soundPlayer.delegate = self
//            soundPlayer.prepareToPlay()
//            soundPlayer.volume = 10.0
//        }
//    }
//
//    // MARK:- AVAudioPlayer delegate methods
//
//    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
//        record.isEnabled = true
//        play.setTitle("Play", for: [])
//    }
//
//    private func audioPlayerDecodeErrorDidOccur(player: AVAudioPlayer, error: NSError?) {
//        print("Error while playing audio \(error!.localizedDescription)")
//    }
//
//    // MARK:- AVAudioRecorder delegate methods
//
//    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
//        play.isEnabled = true
//        record.setTitle("Record", for: [])
//    }
//
//    private func audioRecorderEncodeErrorDidOccur(recorder: AVAudioRecorder, error: NSError?) {
//        print("Error while recording audio \(error!.localizedDescription)")
//    }
//
//    // MARK:- didReceiveMemoryWarning
//
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//    }
//
//    @IBAction func recordSound(_ sender: Any) {
//        if ((sender as AnyObject).titleLabel?.text == "Record"){
//            soundRecorder.record()
//            (sender as AnyObject).setTitle("Stop", for: [])
//            play.isEnabled = false
//        } else {
//            soundRecorder.stop()
//            (sender as AnyObject).setTitle("Record", for: [])
//        }
//    }
//
//
//    @IBAction func playSound(_ sender: Any) {
//        if ((sender as AnyObject).titleLabel?.text == "Play"){
//            record.isEnabled = false
//            (sender as AnyObject).setTitle("Stop", for: [])
//            preparePlayer()
//            soundPlayer.play()
//            print ("play sound")
//        } else {
//            soundPlayer.stop()
//            print ("stop sound")
//            (sender as AnyObject).setTitle("Play", for: [])
//        }
//    }
//
//    func setupRecorder() {
//
//        //set the settings for recorder
//        let recordSettings = [AVSampleRateKey : NSNumber(value: Float(44100.0)),
//                              AVFormatIDKey : NSNumber(value: Int32(kAudioFormatAppleLossless)),
//                              AVNumberOfChannelsKey : NSNumber(value: 2),
//                              AVEncoderAudioQualityKey : NSNumber(value: Int32(AVAudioQuality.max.rawValue))];
//
//        var error: NSError?
//
//        do {
//            //  soundRecorder = try AVAudioRecorder(URL: getFileURL(), settings: recordSettings as [NSObject : AnyObject])
//            soundRecorder =  try AVAudioRecorder(url: getDocumentsDirectory().appendingPathComponent(fileName), settings: recordSettings)
//        } catch let error1 as NSError {
//            error = error1
//            soundRecorder = nil
//        }
//
//        if let err = error {
//            print("AVAudioRecorder error: \(err.localizedDescription)")
//        } else {
//            soundRecorder.delegate = self
//            soundRecorder.prepareToRecord()
//        }
//    }
//}
//

import UIKit
import Foundation
import AVFoundation


class testAudio: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    
    @IBOutlet weak var recordTimeLabel: UILabel!
    @IBOutlet weak var record_btn_ref: UIButton!
    @IBOutlet weak var play_btn_ref: UIButton!
    
    var audioRecorder: AVAudioRecorder!
    var audioPlayer : AVAudioPlayer!
    var meterTimer:Timer!
    var isAudioRecordingGranted: Bool!
    var isRecording = false
    var isPlaying = false
    
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
