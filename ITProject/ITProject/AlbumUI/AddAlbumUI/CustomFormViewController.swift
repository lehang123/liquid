
//
//  CustomFormViewController.swift
//  ITProject
//
//  Created by Erya Wen on 2019/9/9.
//  Copyright © 2019 liquid. All rights reserved.
//


import UIKit
import SwiftEntryKit
import AVFoundation

class CustomFormViewController: UIViewController, AVAudioRecorderDelegate {

    private var contentv : CustomFormView!

    // imagePicker that to open photos library
    private var imagePicker = UIImagePickerController()
    private(set) var albumThumbnailImage : UIImage? = UIImage(named: Util.DEFAULT_IMAGE)
    private(set) var albumThumbnailString: String = Util.DEFAULT_IMAGE
    private var formEle: FormElement!

    
    public func initFormELement(formEle: FormElement){
        self.formEle = formEle
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setView()
        
    }



    private func setView(){

        self.contentv = showPopUpForm(formEle: self.formEle, style: .light)

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
    


    /// Sign up form
    ///
    /// - Parameter formEle: form element
    /// - Parameter style: form style
    private func showPopUpForm(formEle: FormElement,
                                style: FormStyle) -> CustomFormView {
        // set up title style
        let titleStyle = EKProperty.LabelStyle(
            font: MainFont.light.with(size: 14),
            color: style.textColor,
            displayMode: .light
        )
        let title = EKProperty.LabelContent(
            text: formEle.titleText,
            style: titleStyle
        )
        
        // set up textFields
        let textFields = formEle.textFields
        
       // set up button font
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
        
        // Generate the button content
        let buttonsBarContent = EKProperty.ButtonBarContent(
            with: closeButton, okButton,
            separatorColor: Color.Gray.light,
            displayMode: .light,
            expandAnimatedly: true
        )
        
        switch formEle.formType {
        case .withImageView:
            // form type with image view and upload file
            let contentView = CustomFormView(
                with: title,
                textFieldsContent: textFields,
                buttonContent: buttonsBarContent,
                imageViewContent: UIImage(named: Util.DEFAULT_IMAGE)!,
                withUploadFile: true,
                uploadString: formEle.uploadTitle
            )
            contentView.uploadButtonContent.addTarget(self, action: #selector(uploadAction), for: .touchUpInside)
            
            contentView.audioButton.addTarget(self, action: #selector(audioAction), for: .touchUpInside)
            
             return contentView
            
        case .withoutImageView:
            // form type with upload file, without image file
            let contentView = CustomFormView(
                with: title,
                textFieldsContent: textFields,
                buttonContent: buttonsBarContent,
                withUploadFile: true,
                uploadString: formEle.uploadTitle
            )
            contentView.uploadButtonContent.addTarget(self, action: #selector(uploadAction), for: .touchUpInside)
            return contentView
            
        case .defaultForm:
            // form type with text fields only
            let contentView = CustomFormView(
                with: title,
                textFieldsContent: textFields,
                buttonContent: buttonsBarContent
            )
            return contentView
        }

        
       
    }
    
    /// upload the file action
    @objc private func uploadAction() {
        print("addPhotosTapped : Tapped")
        // pop gallery here
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        
        self.present(imagePicker, animated: true, completion:  nil)
    }
    
    // TODO :- ChengHong add your audio action here
    @objc private func audioAction() {
        print("audioButton Touched : Touched")
        
        
    }
    
    /// dismiss pop up form action
    /// - Parameter completion: completion action
    public func dismissWithAnimation(completion: @escaping ((Data?) -> Void) = {_ in }){
        UIView.animate(withDuration: 0.1, delay: 0.0, options:[], animations: {
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0)
        }, completion:{
            bool in
            self.dismiss(animated: true, completion: {
                
                completion(self.contentv.getPreViewImage())
            })
        })
    }
    
}

extension CustomFormViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    /// image picker from photo gallery
    /// - Parameter picker: image picker controller
    /// - Parameter info: <#info description#>
    internal func imagePickerController(_ picker: UIImagePickerController,
                                        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // todo : push add/edit photo view
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            self.albumThumbnailImage =
            editedImage.withRenderingMode(.alwaysOriginal)
        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.albumThumbnailImage = originalImage.withRenderingMode(.alwaysOriginal)
        }
        
        if let im = self.albumThumbnailImage{
            self.contentv.updatePreView(image: im)
        }

        dismiss(animated: true, completion: nil)
    }
    
    /* delegate function from the UIImagePickerControllerDelegate
     called when canceled button pressed, get out of photo library
     */
    
    /// cancel image picker controller
    /// - Parameter picker: image picker controller
    internal func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        print ("imagePickerController: Did canceled pressed !!")
        picker.dismiss(animated: true, completion: nil)
    }
    
    
}
