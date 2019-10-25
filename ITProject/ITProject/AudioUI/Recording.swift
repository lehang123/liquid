//
//  Recording.swift
//  ITProject
//
//  Created by Erya Wen on 2019/10/7.
//  Copyright © 2019 liquid. All rights reserved.
//


import Foundation
import AVFoundation
import QuartzCore



@objc public protocol RecorderDelegate: AVAudioRecorderDelegate {
    @objc optional func audioRecordUpdateMetra(_ metra: Float)
}

open class Recording : NSObject {
    
    // MARK: - Properties
    @objc public enum State: Int {
        case none, record, play
    }
    
    static var directory: String {
        return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    }
    
    open weak var delegate: RecorderDelegate?
    open fileprivate(set) var url: URL
    open fileprivate(set) var state: State = .none
    
    open private(set) var player: AVAudioPlayer?
    
    open var bitRate = 192000
    open var sampleRate = 44100.0
    open var channels = 1
    
    var recorder: AVAudioRecorder?
    
    fileprivate let session = AVAudioSession.sharedInstance()
    fileprivate var link: CADisplayLink?
    
    private var metering: Bool {
        return delegate?.responds(to: #selector(RecorderDelegate.audioRecordUpdateMetra(_:))) == true
    }
    
    // MARK: - Record Methods
    
    /// Initialize a recorder
    /// - Parameter to: path
    public init(to: String) {
        url = URL(fileURLWithPath: Recording.directory).appendingPathComponent(to)
        super.init()
    }
    
    /// prepare recorder
    open func prepare() throws {
        let settings: [String: AnyObject] = [
            AVFormatIDKey : NSNumber(value: Int32(kAudioFormatAppleLossless) as Int32),
            AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue as AnyObject,
            AVEncoderBitRateKey: bitRate as AnyObject,
            AVNumberOfChannelsKey: channels as AnyObject,
            AVSampleRateKey: sampleRate as AnyObject
        ]
        
        recorder = try AVAudioRecorder(url: url, settings: settings)
        recorder?.prepareToRecord()
        recorder?.delegate = delegate
        recorder?.isMeteringEnabled = metering
    }
    
    /// record action
    open func record() throws {
        if recorder == nil {
            try prepare()
        }
        
        try session.setCategory(AVAudioSession.Category.playAndRecord)
        try session.overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
        
        recorder?.record()
        state = .record
        
        if metering {
            startMetering()
        }
    }
    
    // MARK: - Playback Methods
    
    /// Initialize an audio player
    open func initPlayer() throws {
        try session.setCategory(AVAudioSession.Category.playback)
        
        
            player = try AVAudioPlayer(contentsOf: url)
        state = .play
    }
    
    /// delete an audio player
    open func delete(){
        player = nil
    }
    
    /// play the audio
    open func play(){
        player?.play()
    }
    
    /// stop playing audio or stop recording
    open func stop() {
        switch state {
        case .play:
            player?.stop()
            //player = nil
        case .record:
            recorder?.stop()
            recorder = nil
            stopMetering()
        default:
            break
        }
        
        state = .none
    }
    

    
    // MARK: - Metering
    
    /// update volume meter
    @objc func updateMeter() {
        guard let recorder = recorder else { return }
        
        recorder.updateMeters()
        
          let averagePower = recorder.averagePower(forChannel: 0)
          let lowPassResults = pow(10, (0.05 * averagePower)) * 10
          delegate?.audioRecordUpdateMetra?(lowPassResults)
        
    }
    
    /// start meter
    fileprivate func startMetering() {
        link = CADisplayLink(target: self, selector: #selector(Recording.updateMeter))
        link?.add(to: RunLoop.current, forMode: RunLoop.Mode.common)
    }
    
    /// stop metering
    fileprivate func stopMetering() {
        link?.invalidate()
        link = nil
    }
    
}
