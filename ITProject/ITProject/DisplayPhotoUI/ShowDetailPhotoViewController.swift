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
    var cumulativeScale:CGFloat = 1.0
    var maxScale:CGFloat = 3.5
    var minScale:CGFloat = 1.1
    @IBOutlet var imageView: UIImageView!

    
    
    
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
    
    @IBAction func tapBack(_ sender: Any) {
        
        self.dismiss(animated: true)
        
    }
    @objc func pinGesture(_ sender: UIPinchGestureRecognizer) {
        
        if let view = sender.view {

            switch sender.state {
            case .changed:
                let pinchCenter = CGPoint(x: sender.location(in: view).x - view.bounds.midX,
                                          y: sender.location(in: view).y - view.bounds.midY)
                let transform = view.transform.translatedBy(x: pinchCenter.x, y: pinchCenter.y)
                    .scaledBy(x: sender.scale, y: sender.scale)
                    .translatedBy(x: -pinchCenter.x, y: -pinchCenter.y)
                view.transform = transform
                sender.scale = 1
            case .ended:
                // Nice animation to scale down when releasing the pinch.
                // OPTIONAL
                UIView.animate(withDuration: 0.2, animations: {
                    view.transform = CGAffineTransform.identity
                })
            default:
                return
            }
        }
        
        
    }
    
    
}
