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
        let imageUid = Util.GenerateUDID()
        
        // TODO: audio for album in db
        var hasAudio = false
        
        if let audioUrl = audioUrl {
            if Util.DoesFileExist(fullPath: Util.GetDocumentsDirectory().appendingPathComponent(audioUrl).absoluteString){
                
                hasAudio = true
                Util.ReadFileFromDocumentDirectory(fileName: audioUrl, completion: {
                    data in
                    
                    let aUrl = URL(string: audioUrl)?.lastPathComponent
                    Util.UploadFileToServer(data: data, metadata: nil, fileFullName: aUrl!, completion: {
                        url in
                        
                        // upload audio to cloud success
                    })
                })
                
                
            }
        }
        
        Util.UploadFileToServer(data: thumbnail.jpegData(compressionQuality: 1.0)!,
                                metadata: nil,
                                fileName: imageUid!,
                                fextension: Util.EXTENSION_JPEG,
                                completion: { url in
            Util.DismissActivityIndicator()
            if url != nil {
                
                // add album to db
                //TODO: UPLOAD THE AUDIO AS WELL, if hasAudio equal to true
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
                        self.loadAlbumToList(title: albumName,
                                             description: albumDescription,
                                             UID: docRef!.documentID,
                                             coverImageUID: imageUid,
                                             coverImageExtension: Util.EXTENSION_JPEG,
                                             location: currentLocation ??  "",
                                             createDate: createDate)
                    }

                }}
                
                // todo : now expcet album itself, it also upload the image that already choosen.
                
                // todo : create another field for db to record location
                
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
    // Constants and properties go here
    private static let NIB_NAME = "AlbumCollectionViewCell"
    private static let CELL_IDENTIFIER = "AlbumCell"
    private let NO_REPEAT_MESSAGE = "Album name already exist. Try give a unique name"
    private let NON_EMPTY_MESSAGE = "Album name is empty"


    @IBOutlet var albumCollectionView: UICollectionView!

    /// User need to add the album
    /// - Parameter sender: the button for creating album
    @IBAction func AddAlbumPressed(_: Any) {
        print("AddAlbumPressed : ")

        self.performSegue(withIdentifier: Storyboard.presentCreateAlbumVC, sender: self)
        
    }

    /// <#Description#>
    /// Setting up all infomation signed by user to create the album
    /// - Parameter customFormVC: custom Form View Controller
    /// - Returns: formElement: formElement with all information
//    private func setupFormELement(customFormVC: CustomFormViewController) -> FormElement {
//        // initial all text fields needed by creating album form
//        let textFields = AddAlbumUI.fields(by: [.albumName, .albumDescription], style: .light)
//        
//        return .init(formType: .withImageView,
//                     titleText: "Add new album",
//                     textFields: textFields,
//                     uploadTitle: "Upload Thumbnail",
//                     cancelButtonText: "Cancel",
//                     okButtonText: "Create",
//                     cancelAction: {},
//                     okAction: {
//                        // get text filled in album name and description text fields
//                         let albumName = textFields.first!.textContent
//                         let albumDesc = textFields.last!.textContent
//                        // prepare atrributes for pop up alter
//                         let popattributes = PopUpAlter.setupPopupPresets()
//                         if albumName == "" {
//                            // alter if the album name is empty
//                             self.showPopupMessage(attributes: popattributes, description: self.NON_EMPTY_MESSAGE)
//                         } else if self.albumDataList.contains(albumName) {
//                            // alter if the album name repeated
//                             self.showPopupMessage(attributes: popattributes, description: self.NO_REPEAT_MESSAGE)
//                         } else {
//                             // create a album here
//                             customFormVC.dismissWithAnimation {
//                                imageData,_  in
//                                 if let imaged = imageData,
//                                     let imageUid = Util.GenerateUDID() {
//                                     Util.ShowActivityIndicator(withStatus: "Creating album ...")
//                                     Util.UploadFileToServer(data: imaged, metadata: nil, fileName: imageUid, fextension: Util.EXTENSION_JPEG, completion: { url in
//                                         Util.DismissActivityIndicator()
//                                         if url != nil {
//                                             // todo : add the location argument
//                                             AlbumDBController
//                                                .getInstance()
//                                                .addNewAlbum(
//                                                    albumName: albumName,
//                                                    description: albumDesc,
//                                                    thumbnail: imageUid,
//                                                    thumbnailExt: Util.EXTENSION_JPEG,
//                                                    mediaWithin: [],
//                                                    location: "" ,
//                                                    completion: {
//                                                 docRef,_ in
//                                                 
//                                                        self.loadAlbumToList(title: albumName, description: albumDesc, UID: docRef!.documentID, coverImageUID: imageUid, coverImageExtension: Util.EXTENSION_JPEG, location: "")
//                                             })
//                                         }
//
//                                     }, errorHandler: { e in
//                                         print("you get error from Thumbnail choose")
//                                         Util.ShowAlert(title: "Error", message: e!.localizedDescription, action_title: Util.BUTTON_DISMISS, on: self)
//                                     })
//                                 }
//                             }
//                         }
//        })
//    }

    /// Pop up error message
    /// - Parameters:
    ///   - attributes: attributes description
    ///   - description: decription about what is wrong
    private func showPopupMessage(attributes: EKAttributes, description: String) {
        let image = ImageAsset.menu_icon.image.withRenderingMode(.alwaysTemplate)
        let title = "Error!"
        PopUpAlter.showPopupMessage(attributes: attributes,
                                    title: title,
                                    titleColor: .white,
                                    description: description,
                                    descriptionColor: .white,
                                    buttonTitleColor: Color.Gray.mid,
                                    buttonBackgroundColor: .white,
                                    image: image)
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
                                   createDate: createDate)
        
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

    // var activeCell = albumCollectionView
    // activeCell = AlbumCoverViewController.controlView
    private let cellScaling: CGFloat = 0.6
    private let albumsList = AlbumsList()
    private var albumDataList = [String]()

    struct Storyboard {
        static let showAlbumDetail = "ShowAlbumDetail"
        static let presentCreateAlbumVC = "PresentCreateAlbumVC"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        loadAlbumCollectionView()
        //        loadNameData()
        albumCollectionView.reloadData()
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

                // todo : make album's photo according to the photo UID
                let albumUID = albumDetailTVC.albumDetail.UID
                // put it in here : albumDetailTVC.albumContents
                CacheHandler.getInstance().getAllPhotosInfo(currAlbum: albumUID) { detail, error in
                    if let error = error {
                        print("error at prepare AlbumCoverViewController", error)
                    } else {
                        print("AlbumCoverViewC.prepare:::",detail.count)
                        print("AlbumCoverViewC CALL ")
                        albumDetailTVC.reloadPhoto(newPhotos: detail)
                        
                    }
                }
            }
        }else if segue.identifier == Storyboard.presentCreateAlbumVC{
            // Get the presented navigationController and the editViewController it contains
                  let navigationController = segue.destination as! UINavigationController
                  let createAlbumViewController = navigationController.topViewController as! CreateViewController
                  
                  createAlbumViewController.delegate = self
                  createAlbumViewController.creating = .CreateAlbum
        }
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
            // commits delete action to DB:

//            let alertController = UIAlertController(title: "Alert title", message: "Message to display", preferredStyle: .alert)
//
//            // Create OK button
//            let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
//                print("Ok button tapped");
//            }
//            alertController.addAction(OKAction)
//            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action:UIAlertAction!) in
//                print("Cancel button tapped");
//            }
//            alertController.addAction(cancelAction)
//            self.present(alertController, animated: true, completion:nil)
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
