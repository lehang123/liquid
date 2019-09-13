
//
//  CustomFormViewController.swift
//  ITProject
//
//  Created by Erya Wen on 2019/9/9.
//  Copyright © 2019 liquid. All rights reserved.
//

import UIKit
import SwiftEntryKit

class CustomFormViewController: UIViewController {


    var contentv : UIView!
    private var albumCoverViewController : AlbumCoverViewController!
    private var albumDataList : [String] = []
    
    private let REPEATNAME_DES = "Album name already exist. Try give a unique name"
    private let EMPTYNAME_DES = "Album name is empty"
    
    // imagePicker that to open photos library
    private var imagePicker = UIImagePickerController()
    private var albumThumbnailImage : UIImage? = nil
    private var albumThumbnailString: String = "test-small-size-image"

    public func setAlbumCoverViewController(albumCoverViewController : AlbumCoverViewController, albumDataList : [String]){
        self.albumCoverViewController = albumCoverViewController
        self.albumDataList = albumDataList
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setView()
    }
    
    private func setView(){
        var attributes = PopUpFromWindow.setupFormPresets()
        let contentview = showSignupForm(attributes: &attributes, style: .light)
        
        self.view.addSubview(contentview)
        
        contentview.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        contentview.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        contentview.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.8).isActive = true
        contentview.heightAnchor.constraint(equalTo: contentview.heightAnchor).isActive = true
        
        contentview.backgroundColor = .white
        contentview.layer.cornerRadius = 10
        contentview.layer.masksToBounds = true
    
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



    // Sign up form
    private func showSignupForm(attributes: inout EKAttributes, style: FormStyle) -> CustomFormView {
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
            by: [.albumName, .albumDescription],
            style: style
        )
        
       
        let buttonFont = MainFont.medium.with(size: 16)
        
        // ok button setting
        let okButtonLabelStyle = EKProperty.LabelStyle(
            font: buttonFont,
            color: .white,
            displayMode: .light
        )
        let okButtonLabel = EKProperty.LabelContent(
            text: "Create",
            style: okButtonLabelStyle
        )
        let okButton = EKProperty.ButtonContent(
            label: okButtonLabel,
            backgroundColor: UIColor.selfcOrg.ekColor,
            highlightedBackgroundColor: Color.Gray.a800.with(alpha: 0.8),
            displayMode: .light) {
                
                let albumName = textFields.first!.textContent
                let albumDesc = textFields.last!.textContent
                print("albumName", self.albumDataList)
                let popattributes = PopUpAlter.setupPopupPresets()
                if (albumName == "") {
                    self.showPopupMessage(attributes: popattributes, description : self.EMPTYNAME_DES)
                } else if (self.albumDataList.contains(albumName) ){
                    self.showPopupMessage(attributes: popattributes, description : self.REPEATNAME_DES)
                }
                else {
                    // create a album here
                    self.dismissWithAnimation(){

                        // todo : add the thumbnail is a dummy now, and, update cache
                        AlbumDBController.getInstance().addNewAlbum(albumName: albumName, description: albumDesc, thumbnail: self.albumThumbnailString, thumbnailExt: Util.EXTENSION_JPEG, completion: {
                            docRef in
                            print("showSignupForm : are you here ?")
                            self.albumCoverViewController.loadAlbumToList(title: albumName, description: albumDesc, UID: docRef!.documentID, coverImageUID: self.albumThumbnailString, coverImageExtension: Util.EXTENSION_JPEG)
                        })
                    }
                }
        }
        
        
        // close button setting
        let closeButtonLabelStyle = EKProperty.LabelStyle(
            font: buttonFont,
            color: .white,
            displayMode: .light
        )
        let closeButtonLabel = EKProperty.LabelContent(
            text: "Cancel",
            style: closeButtonLabelStyle
        )
        let closeButton = EKProperty.ButtonContent(
            label: closeButtonLabel,
            backgroundColor: .black,
            highlightedBackgroundColor: Color.Gray.a800.with(alpha: 0.8),
            displayMode: .light) {
                
                self.dismissWithAnimation()
        }
        
        // Generate the content
        let buttonsBarContent = EKProperty.ButtonBarContent(
            with: closeButton, okButton,
            separatorColor: Color.Gray.light,
            displayMode: .light,
            expandAnimatedly: true)
        
        
        let contentView = CustomFormView(
            with: title,
            textFieldsContent: textFields,
            buttonContent: buttonsBarContent,
            withUploadFile: true
        )
        
        contentView.uploadButtonContent.addTarget(self, action: #selector(uploadAction), for: .touchUpInside)
        contentView.uploadButtonContent.setImage(albumThumbnailImage ?? UIImage(named: "upload"), for: .normal)
        
        attributes.lifecycleEvents.didAppear = {
            contentView.becomeFirstResponder(with: 0)
        }

        return contentView
    }
    
    @objc private func uploadAction() {
        print("addPhotosTapped : Tapped")
        // pop gallery here
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        
        self.present(imagePicker, animated: true, completion:  nil)
    }
    
    private func dismissWithAnimation(completion: @escaping (() -> Void) = {}){
        UIView.animate(withDuration: 0.1, delay: 0.0, options:[], animations: {
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0)
        }, completion:{
            bool in
            self.dismiss(animated: true, completion: {
                completion()
//                self.albumCoverViewController = nil
            })
        })
    }
    
}

extension CustomFormViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    internal func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//        guard let image = info[.editedImage] as? UIImage else {
//            print("there is no edited Image ")
//            return
//        }
//
//        print ("imagePickerController: Did picked pressed !!")
//        picker.dismiss(animated: true, completion: nil)

        // todo : push add/edit photo view
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            self.albumThumbnailImage =
            editedImage.withRenderingMode(.alwaysOriginal)
        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.albumThumbnailImage = originalImage.withRenderingMode(.alwaysOriginal)
        }
        
        let imageData = self.albumThumbnailImage?.jpegData(compressionQuality: 1.0)
        let imageString = Util.GenerateUDID()!
        Util.UploadFileToServer(data: imageData!, metadata: nil, fileName: imageString, fextension: Util.EXTENSION_JPEG, completion: {_ in
            self.albumThumbnailString = imageString
        }, errorHandler: {e in
                print("you get error from Thumbnail choose")
            Util.ShowAlert(title: "Error", message: e!.localizedDescription, action_title: Util.BUTTON_DISMISS, on: self)
        })
       
        //print("Thumbnail check:", albumThumbnailImage)
        dismiss(animated: true, completion: nil)
    }
    
    /* delegate function from the UIImagePickerControllerDelegate
     called when canceled button pressed, get out of photo library
     */
    internal func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        print ("imagePickerController: Did canceled pressed !!")
        picker.dismiss(animated: true, completion: nil)
    }
    
    
}
