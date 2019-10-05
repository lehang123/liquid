//
//  RecorderViewController.swift
//  ITProject
//
//  Created by Erya Wen on 2019/10/5.
//  Copyright © 2019 liquid. All rights reserved.

import Foundation
import UIKit


class RecorderViewController: UIViewController {

    var recordDuration = 0
    
    @IBOutlet var backgroundView: UIView!
    @IBOutlet weak var recordFinishButton: UIButton!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var voiceView: UIView!
    
    override func viewDidLoad() {
        setupBackgroundView()
        setupRecordFinishButton()
    }
    
    func setupBackgroundView(){
        backgroundView.layer.cornerRadius = 15
        backgroundView.layer.masksToBounds = true
    }
    
    func setupRecordFinishButton(){
        recordFinishButton.addTarget(self, action: #selector(stopRecord), for: .touchUpInside)
    }
    
    @objc func stopRecord() {
          
          dismiss(animated: true, completion: nil)
          
          recordDuration = 0
          
      }
    

}



