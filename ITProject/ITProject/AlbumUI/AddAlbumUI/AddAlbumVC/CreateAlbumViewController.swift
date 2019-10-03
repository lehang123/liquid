//
//  CreateAlbumViewController.swift
//  ITProject
//
//  Created by Gong Lehan on 27/9/19.
//  Copyright © 2019 liquid. All rights reserved.
//

import Foundation
import UIKit
import Gallery
import CoreLocation
//import AVFoundation
//import AVKit


// extension for string to remove whiteSpace
extension String {
    func removingWhitespaces() -> String {
        return components(separatedBy: .whitespaces).joined()
    }
}

class CreateAlbumViewController: UIViewController {
    
    private static let ALBUM_NAME_EMPTY_ALERT_MESSAGE = "album name cannot be empty"
    private static let ALBUM_NAME_EMPTY_ALERT_TITLE = "empty album name"
    private static let ALBUM_NAME_REPEAT_ALERT_MESSAGE = "album name already exist"
    private static let ALBUM_NAME_REPEAT_ALERT_TITLE = "repeat album name"
    private static let DEFAULT_LOCATION_TEXT = "Show current location"
    private static let OK_ACTION = "Ok"
    
    var delegate: CreateAlbumViewControllerDelegate!

    private static let  ADD_PHOTO_TO_ALBUM_BUTTON_LENGTH = 1
    
    var medias = [MediaDetail]()
    
    private var gallery:GalleryController!
    
    private let editor: VideoEditing = VideoEditor()
    // imagePicker that to open photos library
    private var imagePicker:UIImagePickerController!
    
    private let locationManager = CLLocationManager()
    private var cLocation:String = ""
    private var doesLocationShow:Bool = false
    
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var albumNameTextField: UITextField!
    @IBOutlet weak var albumDescriptionTextView: UITextView!
    @IBOutlet weak var addPhotosCollectionView: DynamicHeightCollectionView!
    @IBOutlet weak var thumbnailContentView: UIView!
    
    @IBOutlet var changeThumbnailButton: UIButton!
    @IBOutlet weak var LocationButton: UIButton!
    @IBOutlet var dateLabel: UILabel!
    
    @IBAction func createTapped(_ sender: Any) {
        
        // create new album like the old day
        let nameField = albumNameTextField.text!
    
        if nameField.removingWhitespaces() == ""{
            Util.ShowAlert(title: CreateAlbumViewController.ALBUM_NAME_EMPTY_ALERT_TITLE, message: CreateAlbumViewController.ALBUM_NAME_EMPTY_ALERT_MESSAGE, action_title: CreateAlbumViewController.OK_ACTION, on: self)
        }else if delegate.checkForRepeatName(album: nameField) {
            Util.ShowAlert(title: CreateAlbumViewController.ALBUM_NAME_REPEAT_ALERT_TITLE, message: CreateAlbumViewController.ALBUM_NAME_REPEAT_ALERT_MESSAGE, action_title: CreateAlbumViewController.OK_ACTION, on: self)
        }else {// pass name check start creating album
            dismiss(animated: true, completion: {
                if(self.thumbnailImageView.image == nil){
                    let image = UIImage(withBackground: UIColor.white)
                    self.thumbnailImageView.image = image
                }
                if !self.doesLocationShow{
                    self.delegate.createAlbum(thumbnail: self.thumbnailImageView.image!, photoWithin: self.medias, albumName: nameField, albumDescription: self.albumDescriptionTextView.text, currentLocation: "")
                }else{
                    self.delegate.createAlbum(thumbnail: self.thumbnailImageView.image!, photoWithin: self.medias, albumName: nameField, albumDescription: self.albumDescriptionTextView.text, currentLocation: self.cLocation)
                }
                
            
            })
        }
        
    }
    
    @IBAction func cancelTapped(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func showLocationTapped(_ sender: Any) {
        print(" show location touched ")
        if cLocation.isEmpty{
            retriveCurrentLocation()
            doesLocationShow = true
        }else {
            
            if doesLocationShow {
                doesLocationShow = false;
            LocationButton.setTitle(CreateAlbumViewController.DEFAULT_LOCATION_TEXT, for: .normal)
            }else {
                doesLocationShow = true
                LocationButton.setTitle(cLocation, for: .normal)
            }
        }
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        addPhotosCollectionView.delegate = self
        addPhotosCollectionView.dataSource = self
        self.hideKeyboardWhenTappedAround()
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
//        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width/3, height: UIScreen.main.bounds.width/3)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 5
        addPhotosCollectionView.collectionViewLayout = layout
        
        setupChangeThumbnailButton()
        setupAlbumNameTextField()
        setupDateLabel()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()

    }
    
    func setupAlbumNameTextField(){
        albumNameTextField.delegate = self
        albumNameTextField.backgroundColor = .clear
        albumNameTextField.attributedPlaceholder = NSAttributedString(string: "Album Name", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white.withAlphaComponent(0.8),  NSAttributedString.Key.font : UIFont(name: "DINAlternate-Bold", size: 25)!
        ])
        albumNameTextField.leftViewMode = UITextField.ViewMode.unlessEditing
        let imageView = UIImageView()
        let image = UIImage(named: "editNameIcon")
        imageView.contentMode = .center
        imageView.set(.width, .height, of: 35)
        imageView.image = image
        albumNameTextField.leftView = imageView
    }
    
    func setupChangeThumbnailButton(){
        changeThumbnailButton.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        changeThumbnailButton.setTitle("  Change Thumbnail  ", for: .normal)
    
        changeThumbnailButton.layer.cornerRadius = 10
        changeThumbnailButton.layer.masksToBounds = true
        
           
        changeThumbnailButton.addTarget(self, action: #selector(changeThumbnailAction), for: .touchUpInside)
    }
    
    func setupDateLabel(){
        let currentDate = Date()
        let format = DateFormatter()
        format.dateFormat = "dd.MM.yyyy"
        let formattedDate = format.string(from: currentDate)
        dateLabel.text = formattedDate
        dateLabel.font = UIFont(name: "DINAlternate-Bold", size: 25)
    }
    
    /// change thumbnail action
    @objc private func changeThumbnailAction() {

        // pop gallery here
         print("addThumbnailTapped : tapped")
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
               
        self.present(imagePicker, animated: true, completion:  nil)
        
    }


    
    func retriveCurrentLocation(){
        let status = CLLocationManager.authorizationStatus()

        if(status == .denied || status == .restricted || !CLLocationManager.locationServicesEnabled()){
            // show alert to user telling them they need to allow location data to use some feature of your app
            print("retriveCurrentLocation : rejected")
            return
        }

        // if haven't show location permission dialog before, show it to user
        if(status == .notDetermined){
            locationManager.requestWhenInUseAuthorization()

            // if you want the app to retrieve location data even in background, use requestAlwaysAuthorization
             locationManager.requestAlwaysAuthorization()
            return
        }
        
        // at this point the authorization status is authorized
        // request location data once
        locationManager.requestLocation()
      
        // start monitoring location data and get notified whenever there is change in location data / every few seconds, until stopUpdatingLocation() is called
        locationManager.startUpdatingLocation()
    }
}

extension CreateAlbumViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("textFieldShouldReturn : get called")
        // end editing when user hit return
        textField.endEditing(true)
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        print("textFieldShouldEndEditing : get called")
        return true
    }
}

// we use imagePicker to choose ablum thumb nail since there is only one image allowed
extension CreateAlbumViewController:UIImagePickerControllerDelegate
        ,UINavigationControllerDelegate{

        /// image picker from photo gallery
        /// - Parameter picker: image picker controller
        /// - Parameter info: info
    internal func imagePickerController(_ picker: UIImagePickerController,
                                        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        
        var thumbnailImage:UIImage!
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            thumbnailImage =
            editedImage.withRenderingMode(.alwaysOriginal)
        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            thumbnailImage = originalImage.withRenderingMode(.alwaysOriginal)
        }
        
        if let im = thumbnailImage{
            self.thumbnailImageView.image = im
        }

        dismiss(animated: true, completion: nil)
    }
    
    /* delegate function from the UIImagePickerControllerDelegate
     called when canceled button pressed, get out of photo library
     */
    
    /// cancel image picker controller
    /// - Parameter picker: image picker controller
    internal func imagePickerControllerDidCancel(_ picker: UIImagePickerController){
        
        print ("imagePickerController: Did canceled pressed !!")
        picker.dismiss(animated: true, completion: nil)
    }
}

extension CreateAlbumViewController: CLLocationManagerDelegate {
    // handle delegate methods of location manager here
    
    // called when the authorization status is changed for the core location permission
   func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
           print("location manager authorization status changed")
           
           switch status {
           case .authorizedAlways:
               print("user allow app to get location data when app is active or in background")
           case .authorizedWhenInUse:
               print("user allow app to get location data only when app is active")
           case .denied:
               print("user tap 'disallow' on the permission dialog, cant get location data")
           case .restricted:
               print("parental control setting disallow location data")
           case .notDetermined:
               print("the location permission dialog haven't shown before, user haven't tap allow/disallow")
           @unknown default:
            print("locationManager : error ")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
           // .requestLocation will only pass one location to the locations array
           // hence we can access it by taking the first element of the array
        if let location = locations.first {
            print("locationManager didUpdateLocations : \(location.coordinate.latitude)")
            print("locationManager didUpdateLocations : \(location.coordinate.longitude)")
            
            let geocoder = CLGeocoder()
                    
            // Look up the location and pass it to the completion handler
            geocoder.reverseGeocodeLocation(location,
                        completionHandler: { (placemarks, error) in
                if error == nil {
                    let firstLocation = placemarks?[0]
                    
                    // todo : get erc Library now, depends on your simulator location
                    
                    print("prase location with country : \(firstLocation?.country ?? "unknown country")" )
                    print("prase location with locality : \(firstLocation?.locality ?? "unknown city")" )
                    print("prase location with name : \(firstLocation?.name ?? "unknown name")" )
                    
                    self.cLocation = (firstLocation?.country)! + "." +
                        (firstLocation?.locality)!
                    self.cLocation = self.cLocation + "." + (firstLocation?.name)!
                    
                    self.LocationButton.setTitle(self.cLocation, for: .normal)
                }
            })
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("locationManager didFailWithError : " + error.localizedDescription)
    }
}

extension CreateAlbumViewController: GalleryControllerDelegate{
    
    func galleryController(_ controller: GalleryController, didSelectImages images: [Image]) {
        // todo : need to make sure is thumbnail selecting photo or the photo
        Image.resolve(images: images, completion: {
            uiImages in
            print("galleryController : didSelectImages with length : " + String(uiImages.count))
            // prase each every uiImageTo Media Detail
            
            uiImages.forEach({
                uiImage in
                
                let mediaDetail = MediaDetail(
                    title: "Unknown",
                    description: "None",
                    UID: Util.GenerateUDID(),
                    likes: [],
                    comments: nil,
                    ext: Util.EXTENSION_JPEG,
                    watch: [],
                    audioUID : "")
                mediaDetail.cache = uiImage?.jpegData(compressionQuality: 1.0)
                
                self.addPhotosCollectionView.performBatchUpdates({
                    self.medias.append(mediaDetail)
                    let index = self.medias.count // the lastestUpdate
                    let indexPath = IndexPath(item: index, section: 0)
                    self.addPhotosCollectionView.insertItems(at: [indexPath])
                }, completion: nil)

            })

            controller.dismiss(animated: true, completion: nil)
            self.gallery = nil
        })
        
    }
    
    // when get video
    func galleryController(_ controller: GalleryController, didSelectVideo video: Video) {
        
        controller.dismiss(animated: true, completion: nil)
        gallery = nil
        Util.ShowActivityIndicator(withStatus: "Editing video")
        
        editor.edit(video: video) { (editedVideo: Video?, tempPath: URL?) in
            DispatchQueue.main.async {
                Util.DismissActivityIndicator()
            }
            if let tempPath = tempPath {
                
                 // temp Path :"file:///Users/gonglehan/Library/Developer/CoreSimulator/Devices/68051ACC-8546-4EA1-8DCE-E20B7A4A93F0/data/Containers/Data/Application/75585C1C-A744-4A1C-B25F-C332DF2CEE75/tmp/547CF4AA-3AE9-451A-BA68-16756C89606A.mp4
               
                //init variables:
                let shortPath = tempPath.lastPathComponent as NSString
                let onPath = tempPath.deletingLastPathComponent().absoluteString
                let fileExt = shortPath.pathExtension
                let filename = shortPath.deletingPathExtension
                
                
                print("onPath : " + onPath)
                print("pathExt : " + fileExt)
                print("path : " + filename)
                //zip the file:
                Util.ZipFile(from: onPath as NSString, to: Util.GetVideoDirectory().absoluteString as NSString, fileName: filename, fextension: "." + fileExt, deleteAfterFinish: true){
                    url in
                    
                    let doesFileExist = Util.DoesFileExist(fullPath: url!.absoluteString)
                    print("DOES FILE EXIST AFTER ZIP",url?.absoluteString as Any, doesFileExist )
                }
                 print("FROM NNEW PATH IS : ", onPath)
                print("TO NNEW PATH IS : ", Util.GetVideoDirectory().absoluteString as NSString)
                
                
                
                let media = MediaDetail(
                    title: "a video",
                    description: "this is a video",
                    UID: filename,
                    likes: [],
                    comments: nil,
                    ext: fileExt,
                    watch: [],
                    audioUID: "")
                
                var doesThumbnailMade = false
                video.fetchThumbnail(completion: {
                    thumbnailImage in
                    
                    if !doesThumbnailMade{
                        
                        doesThumbnailMade = true
                           
                        media.cache = thumbnailImage?.jpegData(compressionQuality: 1.0)
                        
                        
                        media.thumbnailUID = filename
                        media.thumbnailExt = Util.EXTENSION_JPEG
                        
                        self.addPhotosCollectionView.performBatchUpdates({
                           self.medias.append(media)
                           let index = self.medias.count // the lastestUpdate
                           let indexPath = IndexPath(item: index, section: 0)
                           self.addPhotosCollectionView.insertItems(at: [indexPath])
                        }, completion: nil)
                    }

                })
            

              // if you want to play the video

            }
        }
    }
    
    func galleryController(_ controller: GalleryController, requestLightbox images: [Image]) {
      
    }
    
    func galleryControllerDidCancel(_ controller: GalleryController) {
        print("galleryController : galleryControllerDidCancel")
        controller.dismiss(animated: true, completion: nil)
    }
}

extension CreateAlbumViewController: UICollectionViewDelegate, UICollectionViewDataSource {
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
        return medias.count + CreateAlbumViewController.ADD_PHOTO_TO_ALBUM_BUTTON_LENGTH
    }

    /// when album on clicked : open albumDetail controller
    /// - Parameters:
    ///   - collectionView: The collection view object that is notifying you of the selection change.
    ///   - indexPath: The index path of the cell that was selected.
    func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    @objc func addPhotoTapped(sender _: UITapGestureRecognizer){
        gallery = GalleryController()
        gallery.delegate = self
        Config.tabsToShow = [.imageTab, .videoTab]
        present(gallery, animated: true, completion: nil)
    }
    
    @objc func photoTapped(_ sender: UITapGestureRecognizer){
        Util.ShowBottomAlertView(on: self, with: [ActionSheetDetail(title: "Delete photo", style: .destructive, action: {
            action in
            print("delete stuffs")
            let cellTapped = sender.view as! AddPhotoCollectionViewCell
            
            self.addPhotosCollectionView.performBatchUpdates({
                
                let theIndex = self.medias.firstIndex(where: {
                    media in
                    if media.UID == cellTapped.UID{
                        if media.getExtension().contains(Util.EXTENSION_MP4) ||
                        media.getExtension().contains(Util.EXTENSION_M4V){
                            // remove the local zip file as well
                            do {
                                let fileToDelete = Util.GetVideoDirectory().appendingPathComponent(media.UID + "." + Util.EXTENSION_ZIP).absoluteString
                                print("It's about the delete : " + fileToDelete)
                                
                                try FileManager.default.removeItem(at: URL(fileURLWithPath: fileToDelete))
                                print("photoTapped : deleting media from local successes")
                            }catch{
                                print("photoTapped : deleting media from local fails")
                            }
                        }
                    }
                    return media.UID == cellTapped.UID
                })
                
                self.medias.remove(at: theIndex!)
                let indexPath = IndexPath(item: theIndex!+1, section: 0)
                self.addPhotosCollectionView.deleteItems(at: [indexPath])
                
            }, completion: nil)
            
            
        }), ActionSheetDetail(title: "Cancel", style: .cancel, action: {
            action in
            print("cancel")
        })])
    }

    /// called in viewDidLoad
    /// - Parameters:
    ///   - collectionView: The collection view object that is notifying you of the selection change.
    ///   - indexPath: The index path of the cell that was selected.
    /// - Returns: A configured cell object.
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
//        print("collectionView how much time did you get called ")
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddPhotoCollectionVewCell", for: indexPath) as! AddPhotoCollectionViewCell
        
        if indexPath.item == 0 {
            cell.TheImageView.image = #imageLiteral(resourceName: "add")
            
            let tapped = UITapGestureRecognizer(target: self, action: #selector(self.addPhotoTapped(sender:)))
            cell.addGestureRecognizer(tapped)
        }else {
            
            cell.UID = medias[indexPath.item-1].UID
            if (indexPath.item)<=medias.count { // make sure not out of bound
                cell.TheImageView.image = UIImage(data: medias[indexPath.item-1].cache)
            }
            
            // tap to delete photo
            let tapped = UITapGestureRecognizer(target: self, action: #selector(self.photoTapped))
            cell.addGestureRecognizer(tapped)
        }
        
        return cell
    }

}


