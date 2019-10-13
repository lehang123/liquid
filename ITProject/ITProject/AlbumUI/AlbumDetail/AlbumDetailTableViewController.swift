//
//  AlbumDetailTableViewController.swift
//  ITProject
//
//  Created by Erya Wen on 2019/8/16.
//  Copyright © 2019 liquid. All rights reserved.
//

import UIKit
import Photos
import SwiftEntryKit
import Firebase


protocol CreateMediaViewControllerDelegate {

    func createMedia(mediaDetail: MediaDetail)
}

protocol AlbumDetailTableViewDelegate {
    func audioPlayFinish()
}

extension AlbumDetailTableViewController:CreateMediaViewControllerDelegate{
    func createMedia(mediaDetail: MediaDetail) {
        
        Util.ShowActivityIndicator(withStatus: "Creating new media...")
        if let imageData = mediaDetail.cache,
           let audioUID = mediaDetail.audioUID,
           let imageUID = mediaDetail.UID{
            
            if !audioUID.removingWhitespaces().isEmpty{
                
                let filename = URL(string: mediaDetail.audioUID)!.appendingPathExtension(Util.EXTENSION_M4A)
                                           
                let audioPath = Util.AUDIO_FOLDER  + "/" + filename.absoluteString
                //uploads audio recorded to the storage:
                Util.ReadFileFromDocumentDirectory(fileName: audioPath){ data in
                  Util.UploadFileToServer(data: data , metadata: nil, fileName: audioUID, fextension: Util.EXTENSION_M4A)
                }
            }
            
        if mediaDetail.getExtension().contains(Util.EXTENSION_M4V) ||
           mediaDetail.getExtension().contains(Util.EXTENSION_MP4) ||
           mediaDetail.getExtension().contains(Util.EXTENSION_MOV){
           
           let videoPath = Util.VIDEO_FOLDER + "/" + mediaDetail.getUID() + "." + Util.EXTENSION_ZIP
           
           print("video path is: ",videoPath)

           //upload vid thumbnail:
           Util.UploadFileToServer(data: imageData, metadata: nil, fileName: imageUID, fextension: Util.EXTENSION_JPEG, completion: {
               url in
               print("COMPLETION 1")
               //upload video itself:
               print("UPLOAD THUMBNAIL SUCCEED")
               Util.ReadFileFromDocumentDirectory(fileName: videoPath){
                   data in
                   print("read finish and there is data")
                   Util.UploadZipFileToServer(data: data, metadata: nil, fileName: imageUID, fextension: mediaDetail.getExtension(), completion: {url in
                      Util.DismissActivityIndicator()
                      if url != nil{
                         //ASSUME THAT PHOTO IS CREATED JUST NOW, I.E. TODAY
                          AlbumDBController
                              .getInstance()
                              .addPhotoToAlbum(
                               desc:mediaDetail.getDescription(),
                               ext: mediaDetail.getExtension(),
                               albumUID: self.albumDetail.UID,
                               mediaPath: imageUID,
                               dateCreated: Timestamp(date: Date()),
                               audioUID: audioUID)
                              
                              self.updatePhoto(
                                  newPhoto: mediaDetail)
                       }
                   })
               }
           })
           
           
       }else {
           // upload image:
           Util.UploadFileToServer(data: imageData, metadata: nil, fileName: imageUID, fextension: mediaDetail.getExtension(), completion: {url in
              Util.DismissActivityIndicator()
              if url != nil{
                 //ASSUME THAT PHOTO IS CREATED JUST NOW, I.E. TODAY
                  AlbumDBController
                      .getInstance()
                      .addPhotoToAlbum(
                       desc:mediaDetail.getDescription(),
                       ext: Util.EXTENSION_JPEG,
                       albumUID: self.albumDetail.UID,
                       mediaPath: imageUID,
                       dateCreated: Timestamp(date: Date()),
                       audioUID: audioUID)
                      
                      self.updatePhoto(
                          newPhoto: mediaDetail)
               }
           })
       }
                                       
        }
    }
}

/// UI View Controller for each Album to be displayed
class AlbumDetailTableViewController: UITableViewController {
    var albumDetail: AlbumDetail!
    
    var albumContents = [MediaDetail]()
    
    /// delete message
    private static let DELETE_PHOTO_TEXT = "Delete photo"
    /// select from album message
    private static let SELECT_FROM_ALBUM_TEXT = "Select from album"
    /// select from album message
    private static let TAKE_PHOTO_TEXT = "Take photo"
    /// cancel message
    private static let CANCEL_TEXT = "Cancel"

    private(set) var displayPhotoCollectionView:UICollectionView?
    
    private static let SHOW_PHOTO_DETAIL_SEGUE = "ShowPhotoDetail"
    
    @IBOutlet weak var albumCoverImageView: UIImageView!
    var headerView : UIView!
    var updateHeaderlayout : CAShapeLayer!
    
    private let headerHeight : CGFloat = 300
    private let headerCut : CGFloat = 80
    
    private var audioPlayer : AVAudioPlayer!
    private var isPlaying = false
    

    
    /// Description
    struct Storyboard {
      
        static let albumDetailDescrpCell = "AlbumDetailDescrpCell"
        static let albumDetailPhotoCell = "AlbumDetailPhotoCell"
        static let presentCreateAlbumVC = "PresentCreateAlbumVC"
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        self.clearsSelectionOnViewWillAppear = false
        Util.CheckPhotoAcessPermission()
        
//        locationManager.delegate = self
//        locationManager.requestWhenInUseAuthorization()
        
        self.navigationItem.title = albumDetail.title
        
        let addPhotos = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addPhotosTapped))
        self.navigationItem.rightBarButtonItem = addPhotos

        Util.GetImageData(imageUID: albumDetail.coverImageUID, UIDExtension: albumDetail.coverImageExtension, completion: {
            data in
            self.albumCoverImageView.image = UIImage(data: data!)
        })

        self.tableView.estimatedRowHeight = self.tableView.rowHeight
        self.tableView.rowHeight = UITableView.automaticDimension
        
        headerView = tableView.tableHeaderView
        updateHeaderlayout = CAShapeLayer()
        self.tableView.UpdateView(headerView: headerView, updateHeaderlayout:
            updateHeaderlayout, headerHeight: headerHeight, headerCut: headerCut)
        
    }
    
    /// reload the album's photos when there is a big change
    /// - Parameter newPhotos: newPhotos

    func reloadPhoto(newPhotos: [MediaDetail]){
 
        self.displayPhotoCollectionView?.performBatchUpdates({
            var indexPaths = [IndexPath]()
            
            if (albumContents.count > 0) {
                for i in 0...albumContents.count - 1 {
                    
//                    self.albumContents.append(newPhotos[i])
                    // first one for description
                    indexPaths.append(IndexPath(item: i, section: 0))
                    print("RUN reloadPhoto")
                }
                self.albumContents.removeAll()
                self.displayPhotoCollectionView?.deleteItems(at: indexPaths)
                indexPaths.removeAll()
            }
            
            print("the length of album  in reloadPhoto is ::: " , self.albumContents.count)
            print("the length of newPhotos  in reloadPhoto is ::: " , newPhotos.count)
            
            if (newPhotos.count  > 0) {
                for i in 0...newPhotos.count - 1 {
                    
                    self.albumContents.append(newPhotos[i])
                    // first one for description
                    indexPaths.append(IndexPath(item: i, section: 0))
                    print("RUN reloadPhoto")
                }
            }
            self.displayPhotoCollectionView?.insertItems(at: indexPaths)
        }, completion: nil)
    }
    
    /// called when new photo get added in and update UI
    /// - Parameter newPhotos: the new photo
    func updatePhoto(newPhoto: MediaDetail){
        if !albumContents.contains(newPhoto){
            self.displayPhotoCollectionView?.performBatchUpdates({
//                albumContents.append(newPhoto)
                self.albumContents.insert(newPhoto, at: 0)
                
                if let index = self.albumContents.firstIndex(of: newPhoto){
                    let indexPath = IndexPath(item: index, section: 0)
                    self.displayPhotoCollectionView?.insertItems(at: [indexPath])
                }
            }, completion: nil)
        }
        
    }

    
    /// add photo button get tapped, pop up add photo form
    @objc private  func addPhotosTapped(){
        print("addPhotosTapped : Tapped")
//        let VC1 = self.storyboard!.instantiateViewController(withIdentifier: "CustomFormViewController") as! CustomFormViewController
//
//           let formEle = self.setupFormELement(customFormVC: VC1)
//           VC1.initFormELement(formEle: formEle)
//           self.present(VC1, animated:true, completion: {
//               VC1.view.backgroundColor = UIColor.black.withAlphaComponent(0.15)
//           })
        
        self.performSegue(withIdentifier: Storyboard.presentCreateAlbumVC, sender: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // reload album data every time load this view
        
        AlbumDBController.getInstance().getAllPhotosInfo(currAlbum: albumDetail.UID) { detail, error in
            if let error = error {
                print("error at prepare AlbumCoverViewController", error)
            } else {
                print("AlbumCoverViewC.prepare:::",detail.count)
                print("AlbumCoverViewC CALL ")
                self.reloadPhoto(newPhotos: detail)
                
            }
        }
    }


    /// view photo detail, present on display photo view controller
    /// - Parameter photoDetail: the photo that user wants to see
    func viewMedia(mediaDetail: MediaDetail) {
        
        self.performSegue(withIdentifier: AlbumDetailTableViewController.SHOW_PHOTO_DETAIL_SEGUE, sender: mediaDetail)
    }
    
    /// prepare for transition for view
    /// - Parameter segue: the segue that triggered
    /// - Parameter sender: the sender
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == AlbumDetailTableViewController.SHOW_PHOTO_DETAIL_SEGUE{
            if let photoDetailTVC = segue.destination as? DisplayPhotoViewController {
                let photoDetail = sender as! MediaDetail
                photoDetailTVC.setMediaDetailData(mediaDetail: photoDetail)
            }
        }else if segue.identifier == Storyboard.presentCreateAlbumVC{
            let navigationController = segue.destination as! UINavigationController
            let createAlbumViewController = navigationController.topViewController as! CreateViewController
                            
            createAlbumViewController.mediaDelegate = self
            createAlbumViewController.creating = .CreateMedia
        }
    }
    
    // MARK: - Table view data source

    /// set number of table view cell
    /// - Parameters:
    ///   - tableView: the tableView
    ///   - section: the section
    ///   - Returns: the number of row that in the section
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
            // 0 - Album Description
            // 1 - Album Photo detail
            return 2
        
    }
    
    /// when touches
    /// - Parameter touches: the touches
    /// - Parameter event: how the touch
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.tableView.decelerationRate = UIScrollView.DecelerationRate.fast
    }
    
    /// when scrollview scroll
    /// - Parameter scrollView: the scrollView
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.tableView.Setupnewview(headerView: headerView, updateHeaderlayout: updateHeaderlayout, headerHeight: headerHeight, headerCut: headerCut)
    }

    

    /// set table view cell
    /// - Parameters:
    ///   - tableView: table view
    ///   - indexPath: indexPath
    /// - Returns: table view cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.albumDetailDescrpCell, for: indexPath) as! AlbumDetailDescrpTableViewCell
            cell.descrp = albumDetail
            cell.audioUID = albumDetail.audioUID
            cell.selectionStyle = .none
            print("AlbumDetailTableViewController.tableView.cell :::", cell)
            
                      if self.albumDetail.audioUID.removingWhitespaces().isEmpty{
                          cell.playAudioButton.isHidden = true
                      }
                      else {
                          Util.GetLocalFileURL(by: self.albumDetail.audioUID, type: .audio, error: {
                              e in
                              if let _ = e {
                                    cell.playAudioButton.isHidden = true
                              }
                        
                          })
                      }
            return cell;
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.albumDetailPhotoCell, for: indexPath) as! AlbumDetailPhotoTableViewCell
            
//            let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressed))
//
//            cell.addGestureRecognizer(longPressRecognizer)
            return cell
            
        }
        
    }
    
//    /// long pressed : used on imageView, when pressed, tried delete
//    /// - Parameter sender: senderGesture, attached on image
//    @objc func longPressed(sender: UILongPressGestureRecognizer)
//    {
//        let actions = [ActionSheetDetail(title: AlbumDetailTableViewController.DELETE_PHOTO_TEXT, style: .destructive, action: { (action) in
//            print("confirmed deleting photo")
//
//            let photo = sender as! AlbumDetailPhotoTableViewCell
////            DBController.getInstance().deleteWholeDocumentfromCollection(documentUID: String, collectionName: <#T##String#>)
////            print(sender)
//        print(action)
//
//        }), ActionSheetDetail(title: AlbumDetailTableViewController.CANCEL_TEXT, style: .cancel, action: { (action) in
//            print("cancelled deleting photo")
//            print(sender)
//
//        }) ]
//        Util.ShowBottomAlertView(on: self, with: actions)
//
//    }
    

    /// set table view delegate and dataSource
    /// - Parameters:
    ///   - tableView: table view
    ///   - cell: table cell
    ///   - indexPath: indexPath
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
    {
        if indexPath.row == 1 {
            if let cell = cell as? AlbumDetailPhotoTableViewCell {
                displayPhotoCollectionView = cell.photoCollectionView
                cell.photoCollectionView.dataSource = self
                cell.photoCollectionView.delegate = self
                cell.photoCollectionView.reloadData()
                cell.photoCollectionView.isScrollEnabled = true
            }
        }
    }


    /// set table view cell height
    /// - Parameters:
    ///   - tableView: table view
    ///   - indexPath: indexPath
    /// - Returns: cell height
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) ->CGFloat {
        if indexPath.row == 1 {
            return self.tableView.bounds.height
        } else {
            return UITableView.automaticDimension
        }
    }
}




// MARK: -  UICollectionViewDataSource
extension AlbumDetailTableViewController: UICollectionViewDataSource
    {
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            
            return albumContents.count
        }

        /* called when photos cell that display photos' thumbnail is visible on device's screen */
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
        {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Storyboard.albumDetailPhotoCell, for: indexPath) as! AlbumDetailPhotoCollectionViewCell
//           cell.image = albumd.getImageList()[indexPath.item]
            let photo = albumContents[indexPath.item]
            cell.mediaUID = photo.UID
            let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressed))
            
            cell.addGestureRecognizer(longPressRecognizer)
            print("AlbumDetailTableViewController : displaying thumbnail : " + photo.getUID())
            
            /* load image with the cell is visible */
            if photo.getExtension().contains(Util.EXTENSION_M4V) ||
                photo.getExtension().contains(Util.EXTENSION_MP4) ||
                photo.getExtension().contains(Util.EXTENSION_MOV){
                print("VIDEO THUMBNAIL GET")
                Util.GetImageData(imageUID: photo.getUID(), UIDExtension: Util.EXTENSION_JPEG, completion: {
                    data in
                    if data != nil{
                        cell.image = UIImage(data: data!)
                    }
                })
            }else{
                print("PHOTO GET")
                Util.GetImageData(imageUID: photo.getUID(), UIDExtension: photo.ext, completion: {
                    data in
                    if data != nil{
                        cell.image = UIImage(data: data!)
                    }
                })
            }
            
            
            return cell
        }
     /// long pressed : used on imageView, when pressed, tried delete
        /// - Parameter sender: senderGesture, attached on image
        @objc func longPressed(sender: UILongPressGestureRecognizer)
        {
            let actions = [ActionSheetDetail(title: AlbumDetailTableViewController.DELETE_PHOTO_TEXT, style: .destructive, action: { (action) in
                print("confirmed deleting photo")
                let photoView: AlbumDetailPhotoCollectionViewCell = sender.view as! AlbumDetailPhotoCollectionViewCell
                
                let index = self.albumContents.firstIndex(where: {
                    media in
                    
                    return media.UID == photoView.mediaUID
                })!
                //remove at DB:
//                print("ext is : ", self.albumContents[photoView.indexInView].ext)

                AlbumDBController.getInstance().deleteMediaFromAlbum(mediaPath: self.albumContents[index].UID, albumUID: self.albumDetail.UID , ext: self.albumContents[index].ext)

                self.displayPhotoCollectionView?.performBatchUpdates({
                    var indexPaths = [IndexPath]()
                    indexPaths.append(IndexPath(row: index, section: 0))
                    
                    self.albumContents.remove(at: index)
                    let indexPath = IndexPath(item: index, section: 0)
                    self.displayPhotoCollectionView?.deleteItems(at: [indexPath])
                    
                }, completion: nil)
                
                
    //            DBController.getInstance().deleteWholeDocumentfromCollection(documentUID: String, collectionName: <#T##String#>)
    //            print(sender)

            }), ActionSheetDetail(title: AlbumDetailTableViewController.CANCEL_TEXT, style: .cancel, action: { (action) in
                print("cancelled deleting photo")
                

            }) ]
            Util.ShowBottomAlertView(on: self, with: actions)
            
        }
    
        /* called when collectionview on touched, go view photos */
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            let media = albumContents[indexPath.item]
            viewMedia(mediaDetail: media)
        }
    }


// MARK: - <#UICollectionViewDelegate, UICollectionViewDelegateFlowLayout#>
extension AlbumDetailTableViewController : UICollectionViewDelegate, UICollectionViewDelegateFlowLayout
    {
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
        {
            let layout = collectionViewLayout as! UICollectionViewFlowLayout
            layout.minimumLineSpacing = 5.0
            layout.minimumInteritemSpacing = 2.5
            let itemWidth = (collectionView.bounds.width - 5.0) / 2.0
            return CGSize(width: itemWidth, height: itemWidth)
        }
}



