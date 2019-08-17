//
//  AlbumnViewController.swift
//  ITProject
//
//  Created by Erya Wen on 2019/8/15.
//  Copyright © 2019 liquid. All rights reserved.
//

import UIKit
import UPCarouselFlowLayout

class AlbumViewController: UIViewController {

    @IBOutlet weak var albumCollectionView: UICollectionView!
    let cellScaling: CGFloat = 0.6
    var albumData = AlbumList.fetchAlbumArray()

    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.albumCollectionView.showsVerticalScrollIndicator = false
        
        albumCollectionView.register(UINib.init(nibName: "AlbumCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "AlbumCell")

   
        

        let layout = albumCollectionView!.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: (albumCollectionView.frame.size.width), height: (albumCollectionView.bounds.size.height)/2.2)
                albumCollectionView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
 
        
    }
    
    // Add new Album
    @IBAction func addNew(_ sender: Any) {
            let a = AlbumList()
       
            a.addNewAlbum(title: "orz", imageName: "item0")
        a.addNewAlbum(title: "orz", imageName: "item1")
        albumData = AlbumList.fetchAlbumArray()
        
            self.albumCollectionView.reloadData()
            
    }
    
    

    

}

extension AlbumViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return albumData.count
    }
    
    
    
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let funct = albumData[(indexPath as NSIndexPath).row]
//
//
//
//    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AlbumCell", for: indexPath) as! AlbumCollectionViewCell
        
        cell.album = albumData[indexPath.item]
        
        return cell
    }
}
