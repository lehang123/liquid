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
        
        //self.imageView = imageView
        imageView.image = selectedImage
        imageView.frame = self.view.bounds
        imageView.backgroundColor = .black
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true

    }
    
    
    @IBAction func TapToBack(_ sender: Any) {
        
        self.dismiss(animated: true)
        
    }
    
    
    
    
    
}
