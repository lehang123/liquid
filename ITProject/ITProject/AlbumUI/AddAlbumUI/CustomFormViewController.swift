
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


    private var contentv : CustomFormView!
    private var albumCoverViewController : AlbumCoverViewController!
    private var albumDataList : [String] = []
    
    
    // imagePicker that to open photos library
    private var imagePicker = UIImagePickerController()
    private var albumThumbnailImage : UIImage? = UIImage(named: "test-small-size-image")
    private var albumThumbnailString: String = "test-small-size-image"
    private var formEle: FormElement!

    public func setAlbumCoverViewController(albumCoverViewController : AlbumCoverViewController, albumDataList : [String], formEle: FormElement){
        self.albumCoverViewController = albumCoverViewController
        self.albumDataList = albumDataList
        self.formEle = formEle
        setView()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //setView()
    }

//    public init(albumCoverViewController : AlbumCoverViewController, albumDataList : [String], formEle: FormElement){
//        self.albumCoverViewController = albumCoverViewController
//        self.albumDataList = albumDataList
//        self.formEle = formEle
//        super.init(nibName: nil, bundle: nil)
//        setView()
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
    private func setView(){
        print("hahah ::: 123\n")
        self.contentv = showSignupForm(formEle: self.formEle, style: .light)

        self.view.addSubview(contentv)

        // constraint
        contentv.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        contentv.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        contentv.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.8).isActive = true
        contentv.heightAnchor.constraint(equalTo: contentv.heightAnchor).isActive = true

        contentv.backgroundColor = .white
        contentv.layer.cornerRadius = 10
        contentv.layer.masksToBounds = true

    }
    


    // Sign up form
    private func showSignupForm(formEle: FormElement,style: FormStyle) -> CustomFormView {
        let titleStyle = EKProperty.LabelStyle(
            font: MainFont.light.with(size: 14),
            color: style.textColor,
            displayMode: .light
        )
        let title = EKProperty.LabelContent(
            text: formEle.titleText,
            style: titleStyle
        )
    
        let textFields = formEle.textFields
        
       
        let buttonFont = MainFont.medium.with(size: 16)
        
        // ok button setting
        let okButtonLabelStyle = EKProperty.LabelStyle(
            font: buttonFont,
            color: .white,
            displayMode: .light
        )
        let okButtonLabel = EKProperty.LabelContent(
            text: formEle.okButtonText,
            style: okButtonLabelStyle
        )
        let okButton = EKProperty.ButtonContent(
            label: okButtonLabel,
            backgroundColor: UIColor.selfcOrg.ekColor,
            highlightedBackgroundColor: Color.Gray.a800.with(alpha: 0.8),
            displayMode: .light) {
                formEle.okAction?()
                
//                let albumName = textFields.first!.textContent
//                let albumDesc = textFields.last!.textContent
//
//                let popattributes = PopUpAlter.setupPopupPresets()
//                if (albumName == "") {
//                    self.showPopupMessage(attributes: popattributes, description : self.EMPTYNAME_DES)
//                } else if (self.albumDataList.contains(albumName) ){
//                    self.showPopupMessage(attributes: popattributes, description : self.REPEATNAME_DES)
//                }
//                else {
//                    // create a album here
//                    self.dismissWithAnimation(){
//
//                        // todo : add the thumbnail is a dummy now, and, update cache
//                        AlbumDBController.getInstance().addNewAlbum(albumName: albumName, description: albumDesc, thumbnail: self.albumThumbnailString, thumbnailExt: Util.EXTENSION_JPEG, completion: {
//                            docRef in
//                            print("showSignupForm : are you here ?")
//                            self.albumCoverViewController.loadAlbumToList(title: albumName, description: albumDesc, UID: docRef!.documentID, coverImageUID: self.albumThumbnailString, coverImageExtension: Util.EXTENSION_JPEG)
//                        })
//                    }
            //}
        }
        
        
        // close button setting
        let closeButtonLabelStyle = EKProperty.LabelStyle(
            font: buttonFont,
            color: .white,
            displayMode: .light
        )
        let closeButtonLabel = EKProperty.LabelContent(
            text: formEle.cancelButtonText,
            style: closeButtonLabelStyle
        )
        var closeButton = EKProperty.ButtonContent(
            label: closeButtonLabel,
            backgroundColor: .black,
            highlightedBackgroundColor: Color.Gray.a800.with(alpha: 0.8),
            displayMode: .light)
        
        let cancelAction = formEle.cancelAction
        closeButton.action = {
            self.dismissWithAnimation()
            cancelAction?()
        }
        
        // Generate the content
        let buttonsBarContent = EKProperty.ButtonBarContent(
            with: closeButton, okButton,
            separatorColor: Color.Gray.light,
            displayMode: .light,
            expandAnimatedly: true
        )
        
        // todo: initial image content
        let contentView = CustomFormView(
            with: title,
            textFieldsContent: textFields,
            buttonContent: buttonsBarContent,
            imageViewContent: UIImage(named: "item4")!,
            withUploadFile: true
        )
        
        contentView.uploadButtonContent.addTarget(self, action: #selector(uploadAction), for: .touchUpInside)
        
        
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
        
        // todo: update image from database
        contentv.resetImage(uiname: "item3")
        
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
