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

class AlbumCoverViewController: UIViewController
{
    

    private static let NIB_NAME = "AlbumCollectionViewCell"
    private static let CELL_IDENTIFIER = "AlbumCell"
    
    private let REPEATNAME_DES = "Album name already exist. Try give a unique name"
    private let EMPTYNAME_DES = "Album name is empty"



    @IBOutlet weak var albumCollectionView: UICollectionView!
    
    @IBAction func AddAlbumPressed(_ sender: Any) {
        print("AddAlbumPressed : ")
//        self.loadNameData()
        
        let VC1 = self.storyboard!.instantiateViewController(withIdentifier: "CustomFormViewController") as! CustomFormViewController
        
        let formEle = self.setupFormELement(customFormVC: VC1)
        VC1.initFormELement(formEle: formEle)
        self.present(VC1, animated:true, completion: {
            VC1.view.backgroundColor = UIColor.black.withAlphaComponent(0.15)
            
        })

    }
    
    private func setupFormELement(customFormVC: CustomFormViewController) -> FormElement{
        let textFields = AddAlbumUI.fields(by: [.albumName,.albumDescription], style: .light)
        return .init(formType: .withImageView,
                     titleText: "Add new album",
                     textFields: textFields,
                     uploadTitle: "Upload Thumbnail",
                     cancelButtonText: "Cancel",
                     okButtonText: "Create",
                     cancelAction:{},
                     okAction: {
        
            let albumName = textFields.first!.textContent
            let albumDesc = textFields.last!.textContent

            let popattributes = PopUpAlter.setupPopupPresets()
            if (albumName == "") {
                self.showPopupMessage(attributes: popattributes, description : self.EMPTYNAME_DES)
            } else if (self.albumDataList.contains(albumName) ){
                self.showPopupMessage(attributes: popattributes, description : self.REPEATNAME_DES)
            }
            else {
                // create a album here
                customFormVC.dismissWithAnimation(){
                    imageData in
                    if let imaged = imageData,
                        let imageUid = Util.GenerateUDID(){
                        Util.ShowActivityIndicator(withStatus: "Creating album ...")
                        Util.UploadFileToServer(data: imaged, metadata: nil, fileName: imageUid, fextension: Util.EXTENSION_JPEG, completion: {url in
                            Util.DismissActivityIndicator()
                            if url != nil{
                                // todo : add the thumbnail is a dummy now, and, update cache
                                AlbumDBController.getInstance().addNewAlbum(albumName: albumName, description: albumDesc, thumbnail: imageUid, thumbnailExt: Util.EXTENSION_JPEG, completion: {
                                    docRef in
                                    print("showSignupForm : are you here ?")
                                    self.loadAlbumToList(title: albumName, description: albumDesc, UID: docRef!.documentID, coverImageUID: imageUid, coverImageExtension: Util.EXTENSION_JPEG)
                                })
                            }
                            
                        }, errorHandler: {e in
                            print("you get error from Thumbnail choose")
                            Util.ShowAlert(title: "Error", message: e!.localizedDescription, action_title: Util.BUTTON_DISMISS, on: self)
                        })
                    }
                }
            }
        })

    }
    
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

    
    //func getAddAlbumPopUpViewSize
    
//    func removeAlbum(albumToDelete : AlbumDetail) {
//        /*take album out of list and refresh*/
//        let index = albumsList.getIndexForItem(album: albumToDelete)
//        albumCollectionView.performBatchUpdates({
//            let indexPath = IndexPath(item: index, section: 0)
//            albumCollectionView.deleteItems(at: [indexPath])
//            albumsList.removeAlbum(albumToDelete: albumToDelete)
//        }, completion: nil)
//    }
    
    func loadAlbumToList(title newAlbumTitle: String,
                  description newAlbumDescrp: String,
                  UID: String,
                  coverImageUID imageUID : String?,
                  coverImageExtension imageExtension : String?,
                  doesReload: Bool = true,
                  reveseOrder: Bool = true){
        
        // todo : this is just a dummy
        print("loadAlbumToList : album is loaded with title : " + newAlbumTitle +
            " with description : " + newAlbumDescrp +
            " with UID " + UID)
        
        let newAlbum = AlbumDetail(title: newAlbumTitle, description: newAlbumDescrp, UID: UID, coverImageUID: imageUID, coverImageExtension: imageExtension)
        
        
        albumCollectionView.performBatchUpdates({
            albumsList.addNewAlbum(newAlbum: newAlbum, addToHead: reveseOrder)
            let index = albumsList.getIndexForItem(album: newAlbum)
            let indexPath = IndexPath(item: index, section: 0)
            albumCollectionView.insertItems(at: [indexPath])
            
        }, completion: nil)
        
        if (doesReload){
            if let albumCollectionView = self.albumCollectionView{
                albumCollectionView.reloadData()
            }
        }
    }
    
    
    //var activeCell = albumCollectionView
    //activeCell = AlbumCoverViewController.controlView
    private let cellScaling: CGFloat = 0.6
    private let albumsList = AlbumsList()
    private var albumDataList = [String]()
    
    
    struct Storyboard {
        static let showAlbumDetail = "ShowAlbumDetail"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadAlbumCollectionView()
        //        loadNameData()
        self.albumCollectionView.reloadData()

    }
    
    
    private func loadAlbumCollectionView(){
        self.albumCollectionView.showsVerticalScrollIndicator = false
        
        albumCollectionView.register(UINib.init(nibName: AlbumCoverViewController.NIB_NAME, bundle: nil), forCellWithReuseIdentifier: AlbumCoverViewController.CELL_IDENTIFIER)
        let layout = albumCollectionView!.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: (albumCollectionView.frame.size.width), height: (albumCollectionView.bounds.size.height) / 2.2)
        albumCollectionView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 9, right: 0)
    }
    
    
    /* prepare next view,
     passing album details to the display album content view
     To-do: changed list data structure so it fits for database */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Storyboard.showAlbumDetail {
            if let albumDetailTVC = segue.destination as? AlbumDetailTableViewController {
                let selectedAlbum = albumsList.getAlbum(index: (sender as! IndexPath).row)
                albumDetailTVC.albumDetail = selectedAlbum

                
                // todo : make album's photo according to the photo UID
                let albumUID = albumDetailTVC.albumDetail.UID
                // put it in here : albumDetailTVC.albumContents
                CacheHandler.getInstance().getAllPhotosInfo(currAlbum: albumUID) { (detail, error) in
                    if let error = error {
                        print("error at prepare AlbumCoverViewController" , error)
                    }
                    else {
                        print("albumUID : " ,albumUID, "name: " , albumDetailTVC.albumDetail.title)
                        albumDetailTVC.albumContents = detail
                        albumDetailTVC.displayPhotoCollectionView?.reloadData()
                        print("detail gilbertttt : ",albumDetailTVC.albumContents.count)
                        //TODO: reload data :
                    }
                }
            }
        }
    }
    

    
  
    private func createAlbumPhotos()->[String]{
        
        var photos = [String]()
        photos.append("test-small-size-image")
        photos.append("test-image-one")
        photos.append("test-image-two")
        
        return photos
    }
}

//protocol RemoveAlbumDelegate {
//
//    func removeAlbum(albumToDelete : AlbumDetail)
//
//}
//
//protocol ReloadDelegate {
//    func loadDataDelegate()
//}

extension AlbumCoverViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // return the number of sections
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return albumsList.count()
    }
    
    /*when album on clicked :
     open albumDetail controller
     */
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        self.performSegue(withIdentifier: Storyboard.showAlbumDetail, sender: indexPath)
    }
    
    
    /*called in viewDidLoad*/
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AlbumCell", for: indexPath) as! AlbumCollectionViewCell
        
 
        cell.album = albumsList.getAlbum(index: indexPath.item)
        
        return cell

    }
    

    
}





