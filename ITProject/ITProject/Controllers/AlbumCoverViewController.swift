//
//  AlbumnViewController.swift
//  ITProject
//
//  Created by Erya Wen on 2019/8/15.
//  Copyright © 2019 liquid. All rights reserved.
//

import UIKit
import UPCarouselFlowLayout
import Firebase
import CleanyModal

class AlbumCoverViewController: UIViewController {
    
    private static let NIB_NAME = "AlbumCollectionViewCell"
    private static let CELL_IDENTIFIER = "AlbumCell"

    @IBOutlet weak var albumCollectionView: UICollectionView!
    
    //var activeCell = albumCollectionView
    //activeCell = AlbumCoverViewController.controlView
    let cellScaling: CGFloat = 0.6
    let albumCoverList = AlbumList()
    var albumList = [String]()
    
    struct Storyboard {
        static let showAlbumDetail = "ShowAlbumDetail"
    }
    


    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadAlbumCollectionView()
        
        //TEMPTESTING
        AlbumDBController.getInstance().getAlbums(familyDocumentReference: CacheHandler.getInstance().getCache(forKey: CacheHandler.FAMILY_KEY as AnyObject) as! DocumentReference) { (querys, err) in

            querys?.documents.forEach({ (querydoc) in
                self.albumList.append(querydoc.data()[AlbumDBController.ALBUM_DOCUMENT_FIELD_NAME] as! String)
            })
        }

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
                let selectedAlbum = albumCoverList.getAlbum(index: (sender as! IndexPath).row)
                albumDetailTVC.albumd = selectedAlbum
            }
        }
    }
    
    // Add new Album
    @IBAction func addNew(_ sender: Any) {
//        let alertConfig = CleanyAlertConfig(
//            title: "Add New Album",
//            message: "",
//            iconImgName: nil)
//        let alert = MyAlertViewController(config: alertConfig)
//        alert.addTextField { textField in
//            textField.placeholder = "Album Name"
//            textField.font = UIFont.systemFont(ofSize: 12)
//            textField.autocorrectionType = .no
//            textField.keyboardAppearance = .dark
//        }
//        alert.addTextField { textField in
//            textField.placeholder = "Description"
//            textField.font = UIFont.systemFont(ofSize: 12)
//            textField.autocorrectionType = .no
//            textField.keyboardAppearance = .dark
//        }
//
//        alert.addAction(title: "Create new Album", style: .default, handler: { action in
//            print("email in textfield is: \(alert.textFields?.first?.text ?? "empty")")
//        })
//        alert.addAction(title: "Cancel", style: .cancel)
//
//        present(alert, animated: true, completion: nil)

        
        AlbumDBController.getInstance().addNewAlbum(albumName: "orz", description: "test backend", completion: {document in
            self.albumCoverList.addNewAlbum(title: "orz", description: "test backend", UID: document!.documentID)
            self.albumCollectionView.reloadData()
        })
            
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
    
//    // For gesture
//    private func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        // If clicked on another cell than the swiped cell
//        let cell = collectionView.cellForItem(at: indexPath)
//        if activeCell != nil && activeCell != cell {
//            userDidSwipeRight()
//        }
//    }
    
}

class MyAlertViewController: CleanyAlertViewController {
    override init(config: CleanyAlertConfig) {
        config.styleSettings[.tintColor] = UIColor(red: 8/255, green: 61/255, blue: 119/255, alpha: 1)
        config.styleSettings[.destructiveColor] = UIColor(red: 218/255, green: 65/255, blue: 103/255, alpha: 1)
        super.init(config: config)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}



