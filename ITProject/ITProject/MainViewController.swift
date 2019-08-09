//
//  MainViewController.swift
//  ITProject
//
//  Created by Gong Lehan on 7/8/19.
//  Copyright © 2019 liquid. All rights reserved.
//

import Foundation
import MongoSwift
import StitchCore
import StitchRemoteMongoDBService
import UIKit
import FirebaseStorage

class MainViewController: UIViewController {
    //Mark: Properties
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        Util.DownloadFileFromServer(fileName: "795C8939-982E-40C8-AE2D-610A6EBA5866.jpg")
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    func downloadImage(from url: URL) {
        print("Download Started")
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            print("Download Finished")
            DispatchQueue.main.async() {
                
                Util.UploadFileToServer(data: data, fextension: Util.EXTENSION_JPEG, fileName: Util.GenerateUDID())
                
                self.imageView.image = UIImage(data: data)
            }
        }
    }
    
}
