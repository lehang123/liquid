//
//  AlbumnViewController.swift
//  ITProject
//
//  Created by Erya Wen on 2019/8/15.
//  Copyright © 2019 liquid. All rights reserved.
//

import UIKit
import UPCarouselFlowLayout

class AlbumCoverViewController: UIViewController {
    
    private static let NIB_NAME = "AlbumCollectionViewCell"
    private static let CELL_IDENTIFIER = "AlbumCell"

    @IBOutlet weak var albumCollectionView: UICollectionView!
    let cellScaling: CGFloat = 0.6
    let albumCoverList = AlbumList()
    
    struct Storyboard {
        static let showAlbumDetail = "ShowAlbumDetail"
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadAlbumCollectionView()
//        Util.ShowActivityIndicator(withStatus: "loading")
//        // todo : load necessary here
//        Util.downloadImage(from: URL (string:"https://cdn.arstechnica.net/wp-content/uploads/2018/06/macOS-Mojave-Dynamic-Wallpaper-transition.jpg")!){
//            data, urlResponse, error in
//            Util.DismissActivityIndicator()
//            if error == nil{
//                // success do stuffs
//                self.albumCoverList.addNewAlbum(title: "a", data: data!)
//                self.albumCoverList.addNewAlbum(title: "a", data: data!)
//                self.albumCoverList.addNewAlbum(title: "a", data: data!)
//                self.albumCoverList.addNewAlbum(title: "a", data: data!)
//                self.albumCoverList.addNewAlbum(title: "a", data: data!)
//                print("AlbumCoverViewController : init ")
//                print( Thread.current)
//                self.albumCollectionView.reloadData()
//            }
//        }
//        loadAlbumCollectionView()
        
        //TEMPTESTING
        self.albumCoverList.addNewAlbum(title: "A", description: "hello1")
        self.albumCoverList.addNewAlbum(title: "SB", description: "hello2",images : [UIImage(named:"item0")!,UIImage(named:"item4")!,UIImage(named:"item3")!,UIImage(named:"item1")!])
        
    }
    
    private func loadAlbumCollectionView(){
        self.albumCollectionView.showsVerticalScrollIndicator = false
        albumCollectionView.register(UINib.init(nibName: AlbumCoverViewController.NIB_NAME, bundle: nil), forCellWithReuseIdentifier: AlbumCoverViewController.CELL_IDENTIFIER)
        let layout = albumCollectionView!.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: (albumCollectionView.frame.size.width), height: (albumCollectionView.bounds.size.height)/2.2)
        albumCollectionView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//
//        // NEED FIXED: Combine AlbumCoverList and TempAlb as one
//        if segue.identifier == Storyboard.showAlbumDetail {
//            if let albumDetailTVC = segue.destination as? AlbumDetailTableViewController {
//                let selectedAlbum = albumCoverList.getAlbum(index: (sender as! IndexPath).row)
//                for i in TempAlbumDetail.fetchPhoto() {
//                    if i.name == selectedAlbum.getTitle() {
//                        albumDetailTVC.albumd = i
//                    }
//                }
//            }
//        }
//    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Storyboard.showAlbumDetail {
            if let albumDetailTVC = segue.destination as? AlbumDetailTableViewController {
                let selectedShoe = albumCoverList.getAlbum(index: (sender as! IndexPath).row)
                albumDetailTVC.albumd = selectedShoe
            }
        }
    }
    
    // Add new Album
    @IBAction func addNew(_ sender: Any) {
    
        albumCoverList.addNewAlbum(title: "orz", description: "hello233", images : [UIImage(named:"item1")!,UIImage(named:"item4")!,UIImage(named:"item3")!,UIImage(named:"item0")!])
        
        self.albumCollectionView.reloadData()
            
    }
}

extension AlbumCoverViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
//        return albumData.count
        return albumCoverList.count()
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        _ = albumData[(indexPath as NSIndexPath).row]

        self.performSegue(withIdentifier: Storyboard.showAlbumDetail, sender: indexPath)

    }
    

    /*called in viewDidLoad*/
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AlbumCell", for: indexPath) as! AlbumCollectionViewCell
        
//        cell.album = albumData[indexPath.item]
        cell.album = albumCoverList.getAlbum(index: indexPath.item)
        
        return cell
    }
}


