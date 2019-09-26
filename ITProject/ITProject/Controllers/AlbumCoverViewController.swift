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

        let VC1 = storyboard!.instantiateViewController(withIdentifier: "CustomFormViewController") as! CustomFormViewController

        let formEle = setupFormELement(customFormVC: VC1)
        VC1.initFormELement(formEle: formEle)
        present(VC1, animated: true, completion: {
            VC1.view.backgroundColor = UIColor.black.withAlphaComponent(0.15)
        })
    }

    /// <#Description#>
    /// Setting up all infomation signed by user to create the album
    /// - Parameter customFormVC: custom Form View Controller
    /// - Returns: formElement: formElement with all information
    private func setupFormELement(customFormVC: CustomFormViewController) -> FormElement {
        // initial all text fields needed by creating album form
        let textFields = AddAlbumUI.fields(by: [.albumName, .albumDescription], style: .light)
        
        return .init(formType: .withImageView,
                     titleText: "Add new album",
                     textFields: textFields,
                     uploadTitle: "Upload Thumbnail",
                     cancelButtonText: "Cancel",
                     okButtonText: "Create",
                     cancelAction: {},
                     okAction: {
                        // get text filled in album name and description text fields
                         let albumName = textFields.first!.textContent
                         let albumDesc = textFields.last!.textContent
                        // prepare atrributes for pop up alter
                         let popattributes = PopUpAlter.setupPopupPresets()
                         if albumName == "" {
                            // alter if the album name is empty
                             self.showPopupMessage(attributes: popattributes, description: self.NON_EMPTY_MESSAGE)
                         } else if self.albumDataList.contains(albumName) {
                            // alter if the album name repeated
                             self.showPopupMessage(attributes: popattributes, description: self.NO_REPEAT_MESSAGE)
                         } else {
                             // create a album here
                             customFormVC.dismissWithAnimation {
                                 imageData in
                                 if let imaged = imageData,
                                     let imageUid = Util.GenerateUDID() {
                                     Util.ShowActivityIndicator(withStatus: "Creating album ...")
                                     Util.UploadFileToServer(data: imaged, metadata: nil, fileName: imageUid, fextension: Util.EXTENSION_JPEG, completion: { url in
                                         Util.DismissActivityIndicator()
                                         if url != nil {
                                             // todo : add the thumbnail is a dummy now, and, update cache
                                             AlbumDBController.getInstance().addNewAlbum(albumName: albumName, description: albumDesc, thumbnail: imageUid, thumbnailExt: Util.EXTENSION_JPEG, completion: {
                                                 docRef in
                                                 print("showSignupForm : are you here ?")
                                                 self.loadAlbumToList(title: albumName, description: albumDesc, UID: docRef!.documentID, coverImageUID: imageUid, coverImageExtension: Util.EXTENSION_JPEG)
                                             })
                                         }

                                     }, errorHandler: { e in
                                         print("you get error from Thumbnail choose")
                                         Util.ShowAlert(title: "Error", message: e!.localizedDescription, action_title: Util.BUTTON_DISMISS, on: self)
                                     })
                                 }
                             }
                         }
        })
    }

    /// Pop up error message
    /// - Parameters:
    ///   - attributes: attributes description
    ///   - description: decription about what is wrong
    private func showPopupMessage(attributes: EKAttributes, description: String) {
        let image = UIImage(named: "menuIcon")!.withRenderingMode(.alwaysTemplate)
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
    ///   - newAlbumTitle: new album title description
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
                         doesReload: Bool = true,
                         reverseOrder: Bool = true) {
        // todo : this is just a dummy
        print("loadAlbumToList : album is loaded with title : " + newAlbumTitle +
            " with description : " + newAlbumDescrp +
            " with UID " + UID)
        
        let newAlbum = AlbumDetail(title: newAlbumTitle, description: newAlbumDescrp, UID: UID, coverImageUID: imageUID, coverImageExtension: imageExtension)
        
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
        layout.itemSize = CGSize(width: albumCollectionView.frame.size.width, height: albumCollectionView.bounds.size.height / 2.2)
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
                        print("albumUID : ", albumUID, "name: ", albumDetailTVC.albumDetail.title)
                        albumDetailTVC.reloadPhoto(newPhotos: detail)
                    }
                }
            }
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
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            // commits delete action to DB:
            let currAlbum: AlbumDetail = self.albumsList.getAlbum(index: indexPath.row)
            AlbumDBController.getInstance().deleteAlbum(albumUID: currAlbum.UID)
            
            //remove from UI:
            self.albumsList.removeAlbum(at: indexPath.row)
            
            
            action.fulfill(with: .delete)
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
