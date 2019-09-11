//
//  ShowDetailPhotoViewController.swift
//  ITProject
//
//  Created by 陳信宏保佑🙏 on 2019/9/10.
//  Copyright © 2019 liquid. All rights reserved.
//

import Foundation
import UIKit

class ShowDetailPhotoViewController: UIViewController {
    //Mark: Properties
    
    var selectedImage: UIImage!
    @IBOutlet weak var imageView: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.image = selectedImage
        imageView.frame = self.view.bounds
        imageView.backgroundColor = .black
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(self.pinGesture))
        imageView.addGestureRecognizer(pinchGesture)

    }
    
    @objc func pinGesture(sender:UIPinchGestureRecognizer) {
        sender.view?.transform = (sender.view?.transform.scaledBy(x: sender.scale, y: sender.scale))!
        sender.scale = 1.0
        
    }
    
    
    @IBAction func TapToBack(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    
    
    
    
}
