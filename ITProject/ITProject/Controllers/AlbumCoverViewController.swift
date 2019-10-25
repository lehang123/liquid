//
//  AlbumnViewController.swift
//  ITProject
//
//  Created by Erya Wen on 2019/8/15.
//  Copyright © 2019 liquid. All rights reserved.
//

import Firebase
import SwiftEntryKit
import SwipeCellKit
import UIKit
import UPCarouselFlowLayout


protocol CreateAlbumViewControllerDelegate {
    func checkForRepeatName(album name: String)->Bool
    func createAlbum(thumbnail :UIImage, photoWithin: [MediaDetail], albumName: String, albumDescription: String, currentLocation: String?, audioUrl : String?, createDate: Date)
}

extension AlbumCoverViewController: CreateAlbumViewControllerDelegate {
    
    
    

    func createAlbum(thumbnail :UIImage,
                     photoWithin: [MediaDetail],
                     albumName: String,
                     albumDescription: String,
                     currentLocation: String?,
                     audioUrl : String?,
                     createDate: Date) {

        Util.ShowActivityIndicator(withStatus: "Creating Album...")
        
        //get image UID:
        let imageUid = Util.GenerateUDID()
        
        

        Util.UploadFileToServer(data: thumbnail.jpegData(compressionQuality: 1.0)!,
                                metadata: nil,
                                fileName: imageUid!,
                                fextension: Util.EXTENSION_JPEG,
                                completion: { url in

            Util.DismissActivityIndicator()
            if url != nil {
                
                //add album to db:
                AlbumDBController
                    .getInstance()
                    .addNewAlbum(
                    albumName: albumName,
                    description: albumDescription,
                    thumbnail: imageUid!,
                    thumbnailExt: Util.EXTENSION_JPEG,
                    mediaWithin: photoWithin,
                    location: currentLocation ?? ""){

                    docRef,error in
                    if let error = error{
                        print("error at AlbumCoverViewController.createAlbum ",error)
                    }else{
                        print("succeed at AlbumCoverViewController.createAlbum ", docRef as Any)
                        
                        var audioUID = ""
                        
                        //now, time to add audio, if there's any:
                        if let audioUrl = audioUrl {
                            if Util.DoesFileExist(fullPath: Util.GetDocumentsDirectory().appendingPathComponent(audioUrl).absoluteString){
                            
                                // upload audio to cloud success
                                let audioURLTmp = URL(string: audioUrl)
                                audioUID = (audioURLTmp?.deletingPathExtension().lastPathComponent)!
                                let audioUID = (audioURLTmp?.deletingPathExtension().lastPathComponent)!
                                
                                Util.ReadFileFromDocumentDirectory(fileName: audioUrl, completion: {
                                    data in
                                    
                                    let aUrl = URL(string: audioUrl)?.lastPathComponent
                                    Util.UploadFileToServer(data: data, metadata: nil, fileFullName: aUrl!, completion: {
                                        url in
                                        
                                        
                                        print("AUDIO UID IS: ", audioUID)
                                        DBController.getInstance().updateSpecificField(newValue: audioUID as Any, fieldName: AlbumDBController.ALBUM_DOCUMENT_FIELD_AUDIO, documentUID: docRef!.documentID, collectionName: AlbumDBController.ALBUM_COLLECTION_NAME)
                                    })
                                })
                            }
                        }
                        self.loadAlbumToList(title: albumName,
                                             description: albumDescription,
                                             UID: docRef!.documentID,
                                             coverImageUID: imageUid,
                                             coverImageExtension: Util.EXTENSION_JPEG,
                                             location: currentLocation ??  "", audioID: audioUID,
                                             createDate: createDate)

                    }

                }}
                
            }, errorHandler: { e in
            print("you get error from Thumbnail choose")
            Util.ShowAlert(title: "Error", message: e!.localizedDescription, action_title: Util.BUTTON_DISMISS, on: self)
        })
    }
    
    func checkForRepeatName(album name: String)->Bool {
        
        return albumsList.fetchAlbumArray().contains(where: {
            album in
            return album.title == name
        })
    }
}

class AlbumCoverViewController: UIViewController {
    // MARK: - Constants and Properties
    struct Storyboard {
        static let showAlbumDetail = "ShowAlbumDetail"
        static let presentCreateAlbumVC = "PresentCreateAlbumVC"
    }
    
    private static let NIB_NAME = "AlbumCollectionViewCell"
    private static let CELL_IDENTIFIER = "AlbumCell"
    private let NO_REPEAT_MESSAGE = "Album name already exist. Try give a unique name"
    private let NON_EMPTY_MESSAGE = "Album name is empty"
    private let cellScaling: CGFloat = 0.6
    private let albumsList = AlbumsList()
    private var albumDataList = [String]()


    @IBOutlet var albumCollectionView: UICollectionView!


    // var activeCell = albumCollectionView
    // activeCell = AlbumCoverViewController.controlView

    // MARK: - Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        loadAlbumCollectionView()
        //        loadNameData()
        albumCollectionView.reloadData()
    }


    /// loads all the albums into UI
    /// - Parameters:
    ///   - newAlbumTitle: new album title
    ///   - newAlbumDescrp: new album descrpiton
    ///   - UID: user id
    ///   - imageUID: imageUID
    ///   - imageExtension: imageExtension
    ///   - doesReload: indicates if we have to reload UI ( default : true)
    ///   - reverseOrder: indicates insertion to UI in reversed order ( default : true)
    func loadAlbumToList(title newAlbumTitle: String,
                         description newAlbumDescrp: String,
                         UID: String,
                         coverImageUID imageUID: String?,
                         coverImageExtension imageExtension: String?,
                         location : String,
                         audioID :String,
                         createDate: Date,
                         doesReload: Bool = true,
                         reverseOrder: Bool = true) {
        // todo : this is just a dummy
        print("loadAlbumToList : album is loaded with title : " + newAlbumTitle +
            " with description : " + newAlbumDescrp +
            " with UID " + UID)
        
        let newAlbum = AlbumDetail(title: newAlbumTitle,
                                   description: newAlbumDescrp,
                                   UID: UID,
                                   coverImageUID: imageUID,
                                   coverImageExtension: imageExtension,
                                   createdLocation : location,
                                   createDate: createDate,
                                   audio: audioID)
        
        albumCollectionView.performBatchUpdates({
            albumsList.addNewAlbum(newAlbum: newAlbum, addToHead: reverseOrder)
            let index = albumsList.getIndexForItem(album: newAlbum)
            let indexPath = IndexPath(item: index, section: 0)
            albumCollectionView.insertItems(at: [indexPath])

        }, completion: nil)

        if doesReload {
            if let albumCollectionView = self.albumCollectionView {
                albumCollectionView.reloadData()
            }
        }
    }

    /// Loads the album collection view for the vc
    private func loadAlbumCollectionView() {
        albumCollectionView.showsVerticalScrollIndicator = false

        albumCollectionView.register(UINib(nibName: AlbumCoverViewController.NIB_NAME, bundle: nil), forCellWithReuseIdentifier: AlbumCoverViewController.CELL_IDENTIFIER)
        let layout = albumCollectionView!.collectionViewLayout as! UICollectionViewFlowLayout
        
        // TODO :- FIX THE WIDTH AND HEIGHT BUG
  
        layout.itemSize = CGSize(width: 320, height: 435 / 2.2)
        albumCollectionView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 9, right: 0)
    
    }
    
    // To-do: changed list data structure so it fits for database
    /// prepare next view, passing album details to the display album content view
    ///
    /// - Parameters:
    ///   - segue: vc you want to go
    ///   - sender: sender
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Storyboard.showAlbumDetail {
            if let albumDetailTVC = segue.destination as? AlbumDetailTableViewController {
                let selectedAlbum = albumsList.getAlbum(index: (sender as! IndexPath).row)
                albumDetailTVC.albumDetail = selectedAlbum

            }
        }else if segue.identifier == Storyboard.presentCreateAlbumVC{
            // Get the presented navigationController and the editViewController it contains
                  let navigationController = segue.destination as! UINavigationController
                  let createAlbumViewController = navigationController.topViewController as! CreateViewController
                  
                  createAlbumViewController.delegate = self
                  createAlbumViewController.creating = .CreateAlbum
        }
    }
    
    
    /// User need to add the album
    /// - Parameter sender: the button for creating album
    @IBAction func AddAlbumPressed(_: Any) {
        print("AddAlbumPressed : ")

        self.performSegue(withIdentifier: Storyboard.presentCreateAlbumVC, sender: self)
        
    }

    /** todo : deprecated */
    private func createAlbumPhotos() -> [String] {
        var photos = [String]()
        photos.append("test-small-size-image")
        photos.append("test-image-one")
        photos.append("test-image-two")

        return photos
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource Extension
extension AlbumCoverViewController: UICollectionViewDelegate, UICollectionViewDataSource, SwipeCollectionViewCellDelegate {
    ///
    /// - Parameter collectionView: The collection view requesting this information.
    /// - Returns: the number of sections
    func numberOfSections(in _: UICollectionView) -> Int {
        return 1
    }

    ///
    /// - Parameters:
    ///   - collectionView: The collection view requesting this information.
    ///   - section: An index number identifying a section in collectionView.
    /// - Returns: The number of rows in section.
    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return albumsList.count()
    }

    /// when album on clicked : open albumDetail controller
    /// - Parameters:
    ///   - collectionView: The collection view object that is notifying you of the selection change.
    ///   - indexPath: The index path of the cell that was selected.
    func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: Storyboard.showAlbumDetail, sender: indexPath)
    }

    /// called in viewDidLoad
    /// - Parameters:
    ///   - collectionView: The collection view object that is notifying you of the selection change.
    ///   - indexPath: The index path of the cell that was selected.
    /// - Returns: A configured cell object.
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AlbumCell", for: indexPath) as! AlbumCollectionViewCell

        cell.album = albumsList.getAlbum(index: indexPath.item)
        cell.delegate = self
        return cell
    }

    ///
    /// - Parameters:
    ///   - collectionView: The collection view object that is notifying you of the selection change.
    ///   - indexPath: The index path of the cell that was selected.
    ///   - orientation: orientation
    /// - Returns: return value
    func collectionView(_: UICollectionView, editActionsForItemAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        
        guard orientation == .right else { return nil }
        
        //detects deletion from swiping gesture:
        
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { deleteAction, indexPath in

            let currAlbum: AlbumDetail = self.albumsList.getAlbum(index: indexPath.row)
            AlbumDBController.getInstance().deleteAlbum(albumUID: currAlbum.UID)

            //remove from UI:
            self.albumsList.removeAlbum(at: indexPath.row)
            deleteAction.fulfill(with: .delete)
        }


        return [deleteAction]
    }

    ///
    /// - Parameters:
    ///   - collectionView: The collection view object that is notifying you of the selection change.
    ///   - indexPath: The index path of the cell that was selected.
    ///   - orientation: orientation
    /// - Returns: return value
    func collectionView(_: UICollectionView, editActionsOptionsForItemAt _: IndexPath, for _: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .destructive
        options.transitionStyle = .drag
       
        return options
    }
}
