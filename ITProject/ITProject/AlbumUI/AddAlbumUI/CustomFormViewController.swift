
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
    private var albumCoverViewController : AlbumCoverViewController?
    private var albumDataList : [String] = []
    
    private let REPEATNAME_DES = "Album name already exist. Try give a unique name"
    private let EMPTYNAME_DES = "Album name is empty"

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
        contentview.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.4).isActive = true
        
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
        
        let okButton = EKProperty.ButtonContent(
            label: .init(text: "Create", style: style.buttonTitle),
            backgroundColor: style.buttonBackground,
            highlightedBackgroundColor: style.buttonBackground.with(alpha: 0.8),
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
                        self.albumCoverViewController?.addAlbum(title: albumName, description: albumDesc, UID: Util.GenerateUDID())
                    }
                }
        }
        
        let buttonFont = MainFont.medium.with(size: 16)
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
            expandAnimatedly: true
        )
        
        let contentView = CustomFormView(
            with: title,
            textFieldsContent: textFields,
            buttonContent: buttonsBarContent
        )
        
        attributes.lifecycleEvents.didAppear = {
            contentView.becomeFirstResponder(with: 0)
        }

        return contentView
    }
    
    private func dismissWithAnimation(completion: @escaping (() -> Void) = {}){
        UIView.animate(withDuration: 0.1, delay: 0.0, options:[], animations: {
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0)
        }, completion:{
            bool in
            self.dismiss(animated: true, completion: {
                completion()
                self.albumCoverViewController = nil
            })
        })
    }
    
}
