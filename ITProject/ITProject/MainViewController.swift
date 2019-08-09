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
        //testDataBase();
        print("UUID: " + Util.GenerateUDID())
        let url = URL(string: "https://cdn.arstechnica.net/wp-content/uploads/2018/06/macOS-Mojave-Dynamic-Wallpaper-transition.jpg")!
        downloadImage(from: url)
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
    
    /*test if mongoDB work test for upload string : success*/
    func testDataBase() {
        do {
            let client =  try Stitch.initializeDefaultAppClient(withClientAppID: "itproject_l-vevre")
            
            let mongoClient = try client.serviceClient(
                fromFactory: remoteMongoClientFactory, withName: "mongodb-atlas"
            )
            
            let coll = mongoClient.db("test_db").collection("test_collection")
            
            client.auth.login(withCredential: AnonymousCredential()) { result in
                switch result {
                case .success(let user):
                    
                    coll.updateOne(
                        filter: ["owner_id": user.id],
                        update: ["number": 47, "owner_id": user.id],
                        options: RemoteUpdateOptions(upsert: true)
                    ) { result in
                        switch result {
                        case .success:
                            coll.find().toArray({ result in
                                switch result {
                                case .success(let result):
                                    print("Found documents:")
                                    
                                    result.forEach({ document in
                                        print(document.canonicalExtendedJSON)
                                    })
                                case .failure(let error):
                                    print("Error in finding documents: \(error)")
                                }
                            })
                            
                        case .failure(let error):
                            print("Error updating or inserting a document: \(error)")
                        }
                    }
                    
                case .failure(let error):
                    print("Error in login: \(error)")
                    
                }
            }
            
        }catch {
            print(error)
        }
        
    }
    
}
