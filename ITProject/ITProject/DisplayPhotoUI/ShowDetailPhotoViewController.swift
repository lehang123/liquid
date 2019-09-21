//
//  ShowDetailPhotoViewController.swift
//  ITProject
//
//  Created by Zhu Chenghong on 2019/9/10.
//  Copyright © 2019 liquid. All rights reserved.
//

import Foundation
import UIKit

/// Description
/// This view controller is mainly show the actually size of the selected picture
/// Users can zoom in and zoom out for detail of the picture
class ShowDetailPhotoViewController: UIViewController, UIScrollViewDelegate {
    
    //Mark: Properties
    var selectedImage: UIImage!
    var cumulativeScale:CGFloat = 1.0
    var maxScale:CGFloat = 3.5
    var minScale:CGFloat = 1.1
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet weak var enterText: UITextField!
    @IBOutlet weak var scrollViewForImage: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setting up the scroll size for each gesture
        self.scrollViewForImage.minimumZoomScale = 1.0
        self.scrollViewForImage.maximumZoomScale = 2.0
        self.scrollViewForImage.contentSize = imageView.bounds.size
        
        // Setting up how the view will be look like after scroll
        imageView.image = selectedImage
        imageView.frame = self.view.bounds
        imageView.backgroundColor = .black
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        
    }
    
    
    /// Description
    /// Zooming for the view
    ///
    /// - Parameter scrollView: the view that user selected
    /// - Returns: the view after scroll
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
    /// Description
    /// End zooming when release pinch guesture
    ///
    /// - Parameters:
    ///   - scrollView: the view that user selected
    ///   - view: view
    ///   - scale: How much the view will be zoomed
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
    }
    
    /// Description
    /// Tap the image again to go back the last view controller
    ///
    /// - Parameter sender: the iamge that user selected
    @IBAction func tapBack(_ sender: Any) {
        if self.imageView.transform != CGAffineTransform.identity {
            self.scrollViewForImage.setZoomScale(1, animated: true)
        }else{
            self.dismiss(animated: true)
        }
    }
    
    
    
}
