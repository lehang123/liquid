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

extension AlbumDetailTableViewController:CreateMediaViewControllerDelegate{
    func createMedia(mediaDetail: MediaDetail) {
        
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
    

//    private let locationManager = CLLocationManager()
    
    // imagePicker that to open photos library
    // private var imagePicker = UIImagePickerController()

    
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
    
    
    /// set up form to ask user to choose an new photo to add
    /// - Parameter customFormVC: the view controller that the form attached to
//    private func setupFormELement(customFormVC: CustomFormViewController) -> FormElement{
//        let textFields = AddAlbumUI.fields(by: [.photoDescription], style: .light)
//
//        return .init(formType: .withImageView,
//                     titleText: "Add new photo",
//                     textFields: textFields,
//                     uploadTitle: "Upload photo",
//                     cancelButtonText: "Cancel",
//                     okButtonText: "Create",
//                     cancelAction:{},
//                     okAction: {
//
//                        customFormVC.dismissWithAnimation(){
//                            imageData,audioUID in
//                            let filename = URL(string: audioUID!)!.appendingPathExtension(Util.EXTENSION_M4A)
//
//                                let audioPath = Util.AUDIO_FOLDER  + "/" + filename.absoluteString
//                                if let imageData = imageData,
//                                   let audioUID = audioUID,let imageUID = Util.GenerateUDID(){
//
//                                   //uploads audio recorded to the storage:
//                                    Util.ReadFileFromDocumentDirectory(fileName: audioPath){ data in
//                                        Util.UploadFileToServer(data: data , metadata: nil, fileName: audioUID, fextension: Util.EXTENSION_M4A)
//                                    }
//
//                                    Util.UploadFileToServer(data: imageData, metadata: nil, fileName: imageUID, fextension: Util.EXTENSION_JPEG, completion: {url in
//                                        Util.DismissActivityIndicator()
//                                        if url != nil{
//                                           //ASSUME THAT PHOTO IS CREATED JUST NOW, I.E. TODAY
//                                            AlbumDBController
//                                                .getInstance()
//                                                .addPhotoToAlbum(
//                                                    desc:textFields.first!.textContent,
//                                                    ext: Util.EXTENSION_JPEG,
//                                                    albumUID: self.albumDetail.UID,
//                                                    mediaPath: imageUID,
//                                                    dateCreated: Timestamp(date: Date()),
//                                                    audioUID: audioUID)
//
//                                                self.updatePhoto(
//                                                    newPhoto: MediaDetail(
//                                                        title: imageUID,
//                                                        description: textFields.first!.textContent,
//                                                        UID: imageUID,
//                                                        likes: [], comments: [], ext: Util.EXTENSION_JPEG,
//                                                        watch: [],
//                                                        audioUID : audioUID))
//                                    }
//                            })
//
//                    }
//            }
//        })
//    }


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
            cell.selectionStyle = .none
            print("AlbumDetailTableViewController.tableView.cell :::", cell)
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

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate
//extension AlbumDetailTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
//
//    internal func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//        guard let image = info[.editedImage] as? UIImage else {
//            print("there is no edited Image ")
//            return
//        }
//
//        print ("imagePickerController: Did picked pressed !!")
//        picker.dismiss(animated: true, completion: nil)
//
//        // todo : push add/edit photo view
//    }
//
//    /* delegate function from the UIImagePickerControllerDelegate
//     called when canceled button pressed, get out of photo library
//     */
//    internal func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
//
//        print ("imagePickerController: Did canceled pressed !!")
//        picker.dismiss(animated: true, completion: nil)
//    }
//
//}


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

//extension AlbumDetailTableViewController: CLLocationManagerDelegate {
//    // handle delegate methods of location manager here
//
//    // called when the authorization status is changed for the core location permission
//   func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
//           print("location manager authorization status changed")
//
//           switch status {
//           case .authorizedAlways:
//               print("user allow app to get location data when app is active or in background")
//           case .authorizedWhenInUse:
//               print("user allow app to get location data only when app is active")
//           case .denied:
//               print("user tap 'disallow' on the permission dialog, cant get location data")
//           case .restricted:
//               print("parental control setting disallow location data")
//           case .notDetermined:
//               print("the location permission dialog haven't shown before, user haven't tap allow/disallow")
//           @unknown default:
//            print("locationManager : error ")
//        }
//    }
//
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//           // .requestLocation will only pass one location to the locations array
//           // hence we can access it by taking the first element of the array
//        if let location = locations.first {
//            print("locationManager didUpdateLocations : \(location.coordinate.latitude)")
//            print("locationManager didUpdateLocations : \(location.coordinate.longitude)")
//
//            let geocoder = CLGeocoder()
//
//            // Look up the location and pass it to the completion handler
//            geocoder.reverseGeocodeLocation(location,
//                        completionHandler: { (placemarks, error) in
//                if error == nil {
//                    let firstLocation = placemarks?[0]
//
//                    // todo : get erc Library now, depends on your simulator location
//                    print("prase location with country : \(firstLocation?.country ?? "unknown country")" )
//                    print("prase location with locality : \(firstLocation?.locality ?? "unknown city")" )
//                    print("prase location with name : \(firstLocation?.name ?? "unknown name")" )
//                }
//            })
//        }
//    }
//
//    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
//        print("locationManager didFailWithError : " + error.localizedDescription)
//    }
//}

