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
    
    @objc public enum State: Int {
        case none, record, play
    }
    
    static var directory: String {
        return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    }
    
    open weak var delegate: RecorderDelegate?
    open fileprivate(set) var url: URL
    open fileprivate(set) var state: State = .none
    
    open var bitRate = 192000
    open var sampleRate = 44100.0
    open var channels = 1
    
    fileprivate let session = AVAudioSession.sharedInstance()
    var recorder: AVAudioRecorder?
    open private(set) var player: AVAudioPlayer?
    fileprivate var link: CADisplayLink?
    
    var metering: Bool {
        return delegate?.responds(to: #selector(RecorderDelegate.audioRecordUpdateMetra(_:))) == true
    }
    
    // MARK: - Initializers
    
    public init(to: String) {
        url = URL(fileURLWithPath: Recording.directory).appendingPathComponent(to)
        super.init()
    }
    
    // MARK: - Record
    
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
    
    // MARK: - Playback
    
    open func initPlayer() throws {
        try session.setCategory(AVAudioSession.Category.playback)
        
        
            player = try AVAudioPlayer(contentsOf: url)
        print("player here :: ", player)
        
//        player?.play()
        state = .play
    }
    
    open func play(){
        player?.play()
    }
    
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
    
    @objc func updateMeter() {
        guard let recorder = recorder else { return }
        
        recorder.updateMeters()
        
          let averagePower = recorder.averagePower(forChannel: 0)
          let lowPassResults = pow(10, (0.05 * averagePower)) * 10
          delegate?.audioRecordUpdateMetra?(lowPassResults)
        
    }
    
    fileprivate func startMetering() {
        link = CADisplayLink(target: self, selector: #selector(Recording.updateMeter))
        link?.add(to: RunLoop.current, forMode: RunLoop.Mode.common)
    }
    
    fileprivate func stopMetering() {
        link?.invalidate()
        link = nil
    }
    
}
