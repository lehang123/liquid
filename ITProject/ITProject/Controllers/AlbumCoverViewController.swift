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
import SwiftEntryKit

class AlbumCoverViewController: UIViewController, RemoveAlbumDelegate
{
    

    private static let NIB_NAME = "AlbumCollectionViewCell"
    private static let CELL_IDENTIFIER = "AlbumCell"

    @IBOutlet weak var albumCollectionView: UICollectionView!
    
    
    func removeAlbum(albumToDelete : AlbumDetail) {
        /*take album out of list and refresh*/
        albumsList.removeAlbum(albumToDelete: albumToDelete)
        self.albumCollectionView.reloadData()
    }
    
    
    //var activeCell = albumCollectionView
    //activeCell = AlbumCoverViewController.controlView
    let cellScaling: CGFloat = 0.6
    let albumsList = AlbumsList()
    var albumDataList = [String]()
    
    
    struct Storyboard {
        static let showAlbumDetail = "ShowAlbumDetail"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadAlbumCollectionView()
        
        //TEMPTESTING

        loadData()
        
    }
    
    
    private func loadAlbumCollectionView(){
        self.albumCollectionView.showsVerticalScrollIndicator = false
        albumCollectionView.register(UINib.init(nibName: AlbumCoverViewController.NIB_NAME, bundle: nil), forCellWithReuseIdentifier: AlbumCoverViewController.CELL_IDENTIFIER)
        let layout = albumCollectionView!.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: (albumCollectionView.frame.size.width), height: (albumCollectionView.bounds.size.height)/2.2)
        albumCollectionView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    private func loadData() {
        AlbumDBController.getInstance().getAlbums(familyDocumentReference: CacheHandler.getInstance().getCache(forKey: CacheHandler.FAMILY_KEY as AnyObject) as! DocumentReference) { (querys, err) in
            
            querys?.documents.forEach({ (querydoc) in
                self.albumDataList.append(querydoc.data()[AlbumDBController.ALBUM_DOCUMENT_FIELD_NAME] as! String)
            })
        }
    }
    
    /* prepare next view,
     passing album details to the display album content view
     To-do: changed list data structure so it fits for database */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Storyboard.showAlbumDetail {
            if let albumDetailTVC = segue.destination as? AlbumDetailTableViewController {
                let selectedAlbum = albumsList.getAlbum(index: (sender as! IndexPath).row)
                albumDetailTVC.albumd = selectedAlbum
            }
        }
    }
    
    // Add new Album
    @IBAction func addNew(_ sender: Any) {
        print("albumList", albumDataList)
        var attributes = PopUpFromWindow.setupFormPresets()
        showSignupForm(attributes: &attributes, style: .light)
//        self.loadData()
        print("123123",self.albumDataList)
        
//        AlbumDBController.getInstance().addNewAlbum(albumName: "orz", description: "test backend", completion: {document in
//            self.albumCoverList.addNewAlbum(title: "orz", description: "test backend", UID: document!.documentID)
//       self.albumCollectionView.reloadData()
//        })
//
        

            
    }
    // pop up alter
    private func showPopupMessage(attributes: EKAttributes) {
        let image = UIImage(named: "menuIcon")!.withRenderingMode(.alwaysTemplate)
        let title = "Error!"
        let description = "Album name already exist. Try give a unique name"
        PopUpAlter.showPopupMessage(attributes: attributes,
                                    title: title,
                                    titleColor: .white,
                                    description: description,
                                    descriptionColor: .white,
                                    buttonTitleColor: Color.Gray.mid,
                                    buttonBackgroundColor: .white,
                                    image: image)
    }
    
    // Sign up form
    private func showSignupForm(attributes: inout EKAttributes, style: FormStyle) {
        let titleStyle = EKProperty.LabelStyle(
            font: MainFont.light.with(size: 14),
            color: style.textColor,
            displayMode: .light
        )
        let title = EKProperty.LabelContent(
            text: "Add new album",
            style: titleStyle
        )
        let textFields = AddAlbumUI.fields(
            by: [.albumName,.albumDescription],
            style: style
        )
        
        let button = EKProperty.ButtonContent(
            label: .init(text: "Continue", style: style.buttonTitle),
            backgroundColor: style.buttonBackground,
            highlightedBackgroundColor: style.buttonBackground.with(alpha: 0.8),
            displayMode: .light) {
                
                /* closure after album confirm created : Main Thread here */
                let albumName = textFields.first?.textContent
                let albumDescription = textFields.last?.textContent
                print("123",self.albumDataList)
                if (albumName != "" && albumName != nil && !self.albumDataList.contains(albumName!)){
                    //
                    //
                    //                } else {
                    //                if (albumName == ""){
                    //                    let popattributes = PopUpAlter.setupPopupPresets()
                    //                    self.showPopupMessage(attributes: popattributes)
                    //                } else {
                    //        AlbumDBController.getInstance().addNewAlbum(albumName: "orz", description: "test backend", completion: {document in
                    //            self.albumCoverList.addNewAlbum(title: "orz", description: "test backend", UID: document!.documentID)
                    // self.albumCollectionView.reloadData()
                    //        })
                    
                    /* make Album photos here
                     TO-DO : this is a dummy only */
                    let albumPhotos = self.createAlbumPhotos()
                    
                    SwiftEntryKit.dismiss()
                    self.albumsList.addNewAlbum(title: albumName!, description: albumDescription ?? "", UID: Util.GenerateUDID(), photos: albumPhotos)
                    
                    self.albumCollectionView.reloadData()
                    
                }
        }
        
        
        
        let contentView = EKFormMessageView(
            with: title,
            textFieldsContent: textFields,
            buttonContent: button
        )
        
        
        
        attributes.lifecycleEvents.didAppear = {
            contentView.becomeFirstResponder(with: 0)
        }
        SwiftEntryKit.display(entry: contentView, using: attributes, presentInsideKeyWindow: true)
    }
    
    private func createAlbumPhotos()->[PhotoDetail]{
        let testPhoto = PhotoDetail(title: "dummy", description: "is it?",
                                    UID : Util.GenerateUDID(), likes: 0,
                                    comments: [PhotoDetail.comment]())
        
        var photos = [PhotoDetail]()
        photos.append(testPhoto)
        return photos
    }
}

protocol RemoveAlbumDelegate {
    
    func removeAlbum(albumToDelete : AlbumDetail)
    
}

protocol ReloadDelegate {
    
    func loadDataDelegate()
    
}

extension AlbumCoverViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
//        return albumData.count
        return albumsList.count()
    }

    /*when album on clicked :
     open albumDetail controller
     */
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        _ = albumData[(indexPath as NSIndexPath).row]

        self.performSegue(withIdentifier: Storyboard.showAlbumDetail, sender: indexPath)

    }
    

    /*called in viewDidLoad*/
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AlbumCell", for: indexPath) as! AlbumCollectionViewCell
//        cell.album = albumData[indexPath.item]
        cell.album = albumsList.getAlbum(index: indexPath.item)
        cell.addRemoveAlbumDelegate(rmd: self)
        cell.cacheAlbumDetail(albumDetail: albumsList.getAlbum(index: indexPath.item))
        
        return cell
    }
    
//    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//        <#code#>
//
//    }
    
    
//    // For gesture
//    private func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        // If clicked on another cell than the swiped cell
//        let cell = collectionView.cellForItem(at: indexPath)
//        if activeCell != nil && activeCell != cell {
//            userDidSwipeRight()
//        }
//    }
    
}




