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

/// UI View Controller for each Album to be displayed
class AlbumDetailTableViewController: UITableViewController {
    var albumDetail: AlbumDetail!
    
    var albumContents = [PhotoDetail]()
    
    /// delete message
    private static let DELETE_PHOTO_TEXT = "Delete Photo"
    /// cancel message
    private static let CANCEL_TEXT = "Cancel"

    private(set) var displayPhotoCollectionView:UICollectionView?
    
    private static let SHOW_PHOTO_DETAIL_SEGUE = "ShowPhotoDetail"
    
    @IBOutlet weak var albumCoverImageView: UIImageView!
    var headerView : UIView!
    var updateHeaderlayout : CAShapeLayer!
    
    private let headerHeight : CGFloat = 300
    private let headerCut : CGFloat = 80
    
    // imagePicker that to open photos library
    private var imagePicker = UIImagePickerController()
    
    /// Description
    struct Storyboard {
      
        static let albumDetailDescrpCell = "AlbumDetailDescrpCell"
        static let albumDetailPhotoCell = "AlbumDetailPhotoCell"
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        self.clearsSelectionOnViewWillAppear = false
        Util.CheckPhotoAcessPermission()
        let addPhotos = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addPhotosTapped))
        self.navigationItem.rightBarButtonItem = addPhotos

//        title = albumd.name
        Util.GetImageData(imageUID: albumDetail.coverImageUID, UIDExtension: albumDetail.coverImageExtension, completion: {
            data in
            self.albumCoverImageView.image = UIImage(data: data!)
        })

        self.tableView.estimatedRowHeight = self.tableView.rowHeight
        self.tableView.rowHeight = UITableView.automaticDimension
        
        headerView = tableView.tableHeaderView
        updateHeaderlayout = CAShapeLayer()
        self.tableView.UpdateView(headerView: headerView, updateHeaderlayout: updateHeaderlayout, headerHeight: headerHeight, headerCut: headerCut)
    }
    
    func reloadPhoto(newPhotos: [PhotoDetail]){
        self.displayPhotoCollectionView?.performBatchUpdates({
            var indexPaths = [IndexPath]()
            //make sure it's clear
            if self.albumContents.count > 0{
                for i in 0...self.albumContents.count - 1 {
                    indexPaths.append(IndexPath(item: i, section: 0))
                }
                self.albumContents.removeAll()
                self.displayPhotoCollectionView?.deleteItems(at: indexPaths)
                indexPaths.removeAll()
            }
            
            if (newPhotos.count - 1 > 0) {
                for i in 0...newPhotos.count - 1 {
                    self.albumContents.append(newPhotos[i])
                    // first one for description
                    indexPaths.append(IndexPath(item: i, section: 0))
                }
            }
            self.displayPhotoCollectionView?.insertItems(at: indexPaths)
        }, completion: nil)
    }
    
    func updatePhoto(newPhotos: PhotoDetail){
        if !albumContents.contains(newPhotos){
            self.displayPhotoCollectionView?.performBatchUpdates({
                albumContents.append(newPhotos)
                
                if let index = self.albumContents.firstIndex(of: newPhotos){
                    let indexPath = IndexPath(item: index, section: 0)
                    self.displayPhotoCollectionView?.insertItems(at: [indexPath])
                }
            }, completion: nil)
        }
        
    }

    
    @objc private  func addPhotosTapped(){
        print("addPhotosTapped : Tapped")
        // pop gallery here
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        
        let VC1 = self.storyboard!.instantiateViewController(withIdentifier: "CustomFormViewController") as! CustomFormViewController
        
        let formEle = self.setupFormELement(customFormVC: VC1)
        VC1.initFormELement(formEle: formEle)
        self.present(VC1, animated:true, completion: {
            VC1.view.backgroundColor = UIColor.black.withAlphaComponent(0.15)

        })
    }
    

    private func setupFormELement(customFormVC: CustomFormViewController) -> FormElement{
        let textFields = AddAlbumUI.fields(by: [.photoDescription], style: .light)
        
        return .init(formType: .withImageView,
                     titleText: "Add new photo",
                     textFields: textFields,
                     uploadTitle: "Upload photo",
                     cancelButtonText: "Cancel",
                     okButtonText: "Create",
                     cancelAction:{},
                     okAction: {
                        /* todo : number of watch and like should be added
                        */

                        customFormVC.dismissWithAnimation(){
                                imageData in
                 
                                if let imageData = imageData,
                                   let imageUID = Util.GenerateUDID(){
                                    
                                    Util.ShowActivityIndicator(withStatus: "Creating photo ...")
                                    Util.UploadFileToServer(data: imageData, metadata: nil, fileName: imageUID, fextension: Util.EXTENSION_JPEG, completion: {url in
                                        Util.DismissActivityIndicator()
                                        if url != nil{
                                            AlbumDBController.getInstance().addPhotoToAlbum(desc:textFields.first!.textContent, ext: Util.EXTENSION_JPEG, albumUID: self.albumDetail.UID, mediaPath: imageUID, dateCreated:   Timestamp(date: Date()))
                                            
                                                self.updatePhoto(newPhotos: PhotoDetail(title: imageUID, description: textFields.first!.textContent, UID: imageUID, likes: 0, comments: nil, ext: Util.EXTENSION_JPEG, watch: 0))

                                    }
                            })
                                
                    }
            }
        })
    }
//            ,
//
//                     errorHandler: { e in
//                        print("you get error from Thumbnail choose")
//                        Util.ShowAlert(title: "Error", message: e!.localizedDescription, action_title: Util.BUTTON_DISMISS, on: self)
//        }
//        )
    
//    func viewPhoto(photoDetail: PhotoDetail) {
//
//        self.performSegue(withIdentifier: AlbumDetailTableViewController.SHOW_PHOTO_DETAIL_SEGUE, sender: photoDetail)
//    }
//
//    }

    /*view photo detail, present on display photo view controller */
    func viewPhoto(photoDetail: PhotoDetail) {
        
        self.performSegue(withIdentifier: AlbumDetailTableViewController.SHOW_PHOTO_DETAIL_SEGUE, sender: photoDetail)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == AlbumDetailTableViewController.SHOW_PHOTO_DETAIL_SEGUE{
            if let photoDetailTVC = segue.destination as? DisplayPhotoViewController {
                let photoDetail = sender as! PhotoDetail
                photoDetailTVC.setPhotoDetailData(photoDetail: photoDetail)
                

            }
        }
    }
    
    // MARK: - Table view data source

    /// set number of table view cell
    ///
    /// - Parameters:
    ///   - tableView: table view
    ///   - section: section description
    /// - Returns: return value description
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
            // 0 - Album Description
            // 1 - Album Photo detail
            return 2
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.tableView.decelerationRate = UIScrollView.DecelerationRate.fast
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.tableView.Setupnewview(headerView: headerView, updateHeaderlayout: updateHeaderlayout, headerHeight: headerHeight, headerCut: headerCut)
    }

    

    /// set table view cell
    ///
    /// - Parameters:
    ///   - tableView: table view
    ///   - indexPath: indexPath
    /// - Returns: table view cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.albumDetailDescrpCell, for: indexPath) as! AlbumDetailDescrpTableViewCell
            cell.descrp = albumDetail
            cell.selectionStyle = .none
            print("AlbumDetailTableViewController.tableView.cell :::", cell)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.albumDetailPhotoCell, for: indexPath) as! AlbumDetailPhotoTableViewCell
            let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressed))
            
            cell.addGestureRecognizer(longPressRecognizer)

            return cell
        }
    }
    
    /// long pressed : used on imageView, when pressed, tried delete
    ///
    /// - Parameter sender: senderGesture, attached on image
    @objc func longPressed(sender: UILongPressGestureRecognizer)
    {
        // Create you actionsheet - preferredStyle: .actionSheet
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let deleteAction = UIAlertAction(title: AlbumDetailTableViewController.DELETE_PHOTO_TEXT, style: .destructive) { (action) in
            print("didPress block")
        }

        let cancelAction = UIAlertAction(title: AlbumDetailTableViewController.CANCEL_TEXT, style: .cancel) { (action) in
            print("didPress cancel")
        }

        // Add the actions to your actionSheet
        actionSheet.addAction(deleteAction)
        actionSheet.addAction(cancelAction)
        // Present the controller
        self.present(actionSheet, animated: true, completion: nil)
    }
    

    /// set table view delegate and dataSource
    ///
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
    ///
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

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate
extension AlbumDetailTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    internal func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else {
            print("there is no edited Image ")
            return
        }
        
        print ("imagePickerController: Did picked pressed !!")
        picker.dismiss(animated: true, completion: nil)
        
        // todo : push add/edit photo view
    }
    
    /* delegate function from the UIImagePickerControllerDelegate
     called when canceled button pressed, get out of photo library
     */
    internal func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        print ("imagePickerController: Did canceled pressed !!")
        picker.dismiss(animated: true, completion: nil)
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

            print("AlbumDetailTableViewController : displaying thumbnail : " + photo.getUID())
            
            /* load image with the cell is visible */
            Util.GetImageData(imageUID: photo.getUID(), UIDExtension: photo.ext, completion: {
                data in
                if data != nil{
                    cell.image = UIImage(data: data!)
                }
            })
            
            return cell
        }
    
        /* called when collectionview on touched, go view photos */
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            let photo = albumContents[indexPath.item]
            viewPhoto(photoDetail: photo)
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

