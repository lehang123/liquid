//
//  AlbumDetailTableViewController.swift
//  ITProject
//
//  Created by Erya Wen on 2019/8/16.
//  Copyright © 2019 liquid. All rights reserved.
//

import UIKit
import Photos

class AlbumDetailTableViewController: UITableViewController {
    var albumDetail: AlbumDetail!
    
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
        checkPermission()
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
    
    func checkPermission() {
        let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        switch photoAuthorizationStatus {
        case .authorized:
            print("checkPermission: Access is granted by user")
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({
                (newStatus) in
                print("checkPermission: status is \(newStatus)")
                if newStatus ==  PHAuthorizationStatus.authorized {
                    /* do stuff here */
                    print("checkPermission: success")
                }
            })
            print("checkPermission: It is not determined until now")
        case .restricted:
            // same same
            print("checkPermission: User do not have access to photo album.")
        case .denied:
            // same same
            print("checkPermission: User has denied the permission.")
        @unknown default:
            print("checkPermission: fatal error.")
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
                     okAction: {}
                    )
        
    }
    
    var displayPhotoViewController : DisplayPhotoViewController?
    
    /*view photo detail, present on display photo view controller */
    func viewPhoto(photoDetail: PhotoDetail) {
        
        self.performSegue(withIdentifier: AlbumDetailTableViewController.SHOW_PHOTO_DETAIL_SEGUE, sender: photoDetail)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == AlbumDetailTableViewController.SHOW_PHOTO_DETAIL_SEGUE{
            if let photoDetailTVC = segue.destination as? DisplayPhotoViewController {
                let photoDetail = sender as! PhotoDetail
                photoDetailTVC.setPhotoUID(photoUID: photoDetail.getUID())
            }
        }
    }
    
    // MARK: - Table view data source

    /// Description
    ///
    /// - Parameters:
    ///   - tableView: <#tableView description#>
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

    

    /// <#Description#>
    ///
    /// - Parameters:
    ///   - tableView: <#tableView description#>
    ///   - indexPath: <#indexPath description#>
    /// - Returns: <#return value description#>
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

            return cell
        }
    }

    /// <#Description#>
    ///
    /// - Parameters:
    ///   - tableView: <#tableView description#>
    ///   - cell: <#cell description#>
    ///   - indexPath: <#indexPath description#>
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
    {
        if indexPath.row == 1 {
            if let cell = cell as? AlbumDetailPhotoTableViewCell {
                cell.photoCollectionView.dataSource = self
                cell.photoCollectionView.delegate = self
                cell.photoCollectionView.reloadData()
                cell.photoCollectionView.isScrollEnabled = true
                
            }
        }
    }


    /// <#Description#>
    ///
    /// - Parameters:
    ///   - tableView: <#tableView description#>
    ///   - indexPath: <#indexPath description#>
    /// - Returns: <#return value description#>
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) ->CGFloat {
        if indexPath.row == 1 {
            return self.tableView.bounds.height
        } else {
            return UITableView.automaticDimension
        }
    }
}

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


// TODO: finish collection view controller
// MARK : UICollectionViewDataSource

extension AlbumDetailTableViewController: UICollectionViewDataSource
    {
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return albumDetail.photos.count
        }

        /* called when photos cell that display photos' thumbnail is visible on device's screen */
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
        {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Storyboard.albumDetailPhotoCell, for: indexPath) as! AlbumDetailPhotoCollectionViewCell
//           cell.image = albumd.getImageList()[indexPath.item]
            let photo = albumDetail.photos[indexPath.item]

            print("AlbumDetailTableViewController : displaying thumbnail : " + photo.getUID())
            
            /* load image with the cell is visible */
            Util.GetImageData(imageUID: photo.getUID(), UIDExtension: Util.EXTENSION_JPEG, completion: {
                data in
                if data != nil{
                    cell.image = UIImage(data: data!)
                }
            })
            
            return cell
        }
    
        /* called when collectionview on touched, go view photos */
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            let photo = albumDetail.photos[indexPath.item]
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

