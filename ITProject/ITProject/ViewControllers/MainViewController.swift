//
//  MainViewController.swift
//  ITProject
//
//  Created by Gong Lehan on 7/8/19.
//  Copyright © 2019 liquid. All rights reserved.
//

import Foundation
import UIKit
import FirebaseStorage

class MainViewController: UIViewController {
    //Mark: Properties
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    
        /* test for downloading from sever */
        Util.DownloadFileFromServer(fileName: "795C8939-982E-40C8-AE2D-610A6EBA5866.jpg")
    }
    
    
}
