//
//  RecorderViewController.swift
//  ITProject
//
//  Created by Erya Wen on 2019/10/5.
//  Copyright © 2019 liquid. All rights reserved.

import Foundation
import UIKit
import Dollar

protocol RecorderViewDelegate : class {
    func didFinishRecording(_ recorderViewController: RecorderViewController)
}

class RecorderViewController: UIViewController , RecorderDelegate {
    //MARK : - Properties
    open weak var delegate: RecorderViewDelegate?
    
    var destinationUrl: String!
    var recording: Recording!
    var recordDuration = 0

    @IBOutlet var backgroundView: UIView!
    @IBOutlet weak var tapToFinishBtn: UIButton!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet var singalImageView: UIImageView!
    
    // MARK: - Public Methods
    /// Initialize a recorder
    open func createRecorder() {
        recording = Recording(to: destinationUrl)
        recording.delegate = self
        
        // Optionally, you can prepare the recording in the background to
        // make it start recording faster when you hit `record()`.
        
        DispatchQueue.global().async {
            // Background thread
            do {
                try self.recording.prepare()
            } catch {
                print(error)
            }
        }
    }
    
    /// Start recording action
    open func startRecording() {
        recordDuration = 0
        do {
            try recording.record()
        } catch {
            print(error)
        }
    }
    
    // MARK: - Private Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackgroundView()
        createRecorder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        durationLabel.text = ""

    }
    
    /// Set up recorder background view
    func setupBackgroundView(){
        backgroundView.layer.cornerRadius = 15
        backgroundView.layer.masksToBounds = true
    }
    
    // Stop recording action
    @IBAction func stopRecord() {
        
        delegate?.didFinishRecording(self)
        dismiss(animated: true, completion: nil)
        
        recordDuration = 0
        recording.stop()
        
    }
    
    /// update recorder volume UI with volume changing
    /// - Parameter value: volume value
    func audioRecordUpdateMetra(_ value: Float) {
        //print("db level: %f", value)
        
        self.recording.recorder?.updateMeters()
        var index = Int(round(value))
        index = index > 7 ? 7 : index
        index = index < 0 ? 0 : index

        let array = [
            ImageAsset.recording_Signal_1.image,
            ImageAsset.recording_Signal_2.image,
            ImageAsset.recording_Signal_3.image,
            ImageAsset.recording_Signal_4.image,
            ImageAsset.recording_Signal_5.image,
            ImageAsset.recording_Signal_6.image,
            ImageAsset.recording_Signal_7.image,
            ImageAsset.recording_Signal_8.image,
        ]
        self.singalImageView.image = Dollar.fetch(array, index)
       
        recordDuration += 1
        
        let (minute, second) = Util.secondsToMinutesSeconds(seconds : recordDuration)
        let times:String = ("\(minute):\(second)")
        durationLabel.text = times
    }
    

}
