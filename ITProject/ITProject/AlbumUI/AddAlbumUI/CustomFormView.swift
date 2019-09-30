//
//  CustomFormView.swift
//  ITProject
//
//  Created by Erya Wen on 2019/9/9.
//  Copyright © 2019 liquid. All rights reserved.
//
//  SwiftEntryKit (Created by Daniel Huri on 5/16/18.) Extension
//  EKFormMessageView+validation+uploadFile


import UIKit
import SwiftEntryKit
import Foundation
import AVFoundation

class CustomFormView: UIView {
    
    
    private let scrollViewVerticalOffset: CGFloat = 20
    private let titleLabel = UILabel()
    private let scrollView = UIScrollView()
    private var imageView = UIImageView()
    private let textFieldsContent: [CustomTextFieldContent]
    private var textFieldViews: [CustomTextField] = []
    private var buttonBarView: EKButtonBarView!
    private var imageViewContent: UIImage?
    private(set) var uploadButtonContent = UIButton()
    private var withUploadFile = false
    private(set) var audioButton = UIButton()

    
//    private var imagePicker = UIImagePickerController()
    
    private let titleContent: EKProperty.LabelContent
    
    // MARK: Setup
    
    /// initial default type form
    /// - Parameter title: form title
    /// - Parameter textFieldsContent: form textFields
    /// - Parameter buttonContent: button content
    /// - Parameter withUploadFile: if it required upload file field (default is false)
    /// - Parameter uploadString: upload field title
    public init(with title: EKProperty.LabelContent,
                textFieldsContent: [CustomTextFieldContent],
                buttonContent: EKProperty.ButtonBarContent,
                withUploadFile: Bool? = false,
                uploadString: String? = "") {
        self.titleContent = title
        self.textFieldsContent = textFieldsContent
        self.withUploadFile = withUploadFile!
        super.init(frame: UIScreen.main.bounds)
        setupScrollView()
        setupTitleLabel()
        setupTextFields(with: textFieldsContent)
        setupUploadView(uploadTitle: uploadString ?? "")
        setupButton(with: buttonContent)
        setupTapGestureRecognizer()
        scrollView.layoutIfNeeded()
        set(.height,
            of: scrollView.contentSize.height + scrollViewVerticalOffset * 2,
            priority: .defaultHigh)
    }
    
    /// initial form with upload image content
    /// - Parameter title: form title
    /// - Parameter textFieldsContent: form textFields
    /// - Parameter buttonContent: button content
    /// - Parameter imageViewContent: image view content
    /// - Parameter withUploadFile: if it required upload file field (default is false)
    /// - Parameter uploadString: upload field title
    public init(with title: EKProperty.LabelContent,
                textFieldsContent: [CustomTextFieldContent],
                buttonContent: EKProperty.ButtonBarContent,
                imageViewContent: UIImage,
                withUploadFile: Bool? = false,
                uploadString: String? = "") {
        self.titleContent = title
        self.textFieldsContent = textFieldsContent
        self.imageViewContent = imageViewContent
        self.withUploadFile = withUploadFile!
        super.init(frame: UIScreen.main.bounds)
        setupScrollView()
        setupTitleLabel()
        setupImageView()
        setupAudioButton()
        setupTextFields(with: textFieldsContent)
        setupUploadView(uploadTitle: uploadString ?? "")
        setupButton(with: buttonContent)
        setupTapGestureRecognizer()
        scrollView.layoutIfNeeded()
        set(.height,
            of: scrollView.contentSize.height,
            priority: .defaultHigh)
    }
    
    
    /// initial fails
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK:- Set Up
    
    /// set up scroll view
    private func setupScrollView() {
        addSubview(scrollView)
        scrollView.layoutToSuperview(axis: .horizontally, offset: 20)
        scrollView.layoutToSuperview(axis: .vertically, offset: scrollViewVerticalOffset)
        scrollView.layoutToSuperview(.width, .height, offset: -scrollViewVerticalOffset * 2)
    }
    
    /// set up form title layout
    private func setupTitleLabel() {
        scrollView.addSubview(titleLabel)
        titleLabel.layoutToSuperview(.top, .width)
        titleLabel.layoutToSuperview(axis: .horizontally)
        titleLabel.forceContentWrap(.vertically)
        titleLabel.content = titleContent
    }
    
    /// set up image view content layout
    private func setupImageView(){
        scrollView.addSubview(imageView)
        imageView.layout(.top, to: .bottom, of: titleLabel, offset: 20)
        imageView.layoutToSuperview(.centerX)
        imageView.contentMode = .scaleAspectFit
        //imageView.layoutToSuperview(.top, offset: 10)
        imageView.layoutToSuperview(.width, offset: -20)
   
        // to-do: fix height
        imageView.heightAnchor.constraint(equalTo: self.imageView.widthAnchor, multiplier: 0.5).isActive = true
        imageView.image = imageViewContent
        
        self.layoutIfNeeded()
        
    }
    
    private func setupAudioButton(){
        scrollView.addSubview(audioButton)
        audioButton.layoutToSuperview(.centerX)
        audioButton.layout(.top, to: .bottom, of: uploadButtonContent, offset: 20)
        audioButton.layoutToSuperview(.width, offset: -40)
        audioButton.heightAnchor.constraint(equalTo: self.audioButton.widthAnchor, multiplier: 0.2).isActive = true
        uploadButtonContent.layer.cornerRadius = 5
        
        audioButton.backgroundColor = UIColor.selfcOrg.withAlphaComponent(0.2)
        audioButton.setTitle("Audio Test", for: .normal)
        audioButton.setImage(UIImage(named: "uploadIcon"), for: .normal)


        audioButton.setTitleColor(.gray, for: .normal)
        audioButton.setTitleColor(UIColor.black, for: .highlighted)
        
        
        audioButton.imageEdgeInsets = UIEdgeInsets(top: 0,left: 0,bottom: 0,right: 34)
        audioButton.titleEdgeInsets = UIEdgeInsets(top: 6,left: 20,bottom: 6,right: 14)
        
        
        let buttonWidth = scrollView.frame.width - 115
        let bound = CGRect(x: 0,y: 0, width: buttonWidth, height: buttonWidth * 0.2)
        
        audioButton.createDashedLine(bound: bound, color: .selfcOrg, strokeLength: 8, gapLength: 6, width: 2)
        
        
        self.layoutIfNeeded()
        
    }
    

    
    /// set up text fields layout
     /// - Parameter textFieldsContent: form textFields content
     private func setupTextFields(with textFieldsContent: [CustomTextFieldContent]) {
         var textFieldIndex = 0
         textFieldViews = textFieldsContent.map { content -> CustomTextField in
             let textField = CustomTextField(with: content)
             scrollView.addSubview(textField)
             textField.tag = textFieldIndex
             textFieldIndex += 1
             return textField
         }
         if(imageViewContent != nil) {
         textFieldViews.first!.layout(.top, to: .bottom, of: imageView, offset: 20)
         } else {
             textFieldViews.first!.layout(.top, to: .bottom, of: titleLabel, offset: 20)
         }
         
         textFieldViews.spread(.vertically, offset: 5)
         textFieldViews.layoutToSuperview(axis: .horizontally)
     }
    
    
    /// set up upload field layout
    /// - Parameter uploadTitle: upload field string
    private func setupUploadView(uploadTitle: String) {
        if(withUploadFile){
            scrollView.addSubview(uploadButtonContent)
            uploadButtonContent.layoutToSuperview(.centerX)
            uploadButtonContent.layout(.top, to: .bottom, of: textFieldViews.last!, offset: 20)
            uploadButtonContent.layoutToSuperview(.width, offset: -40)
            uploadButtonContent.heightAnchor.constraint(equalTo: self.uploadButtonContent.widthAnchor, multiplier: 0.2).isActive = true
            uploadButtonContent.layer.cornerRadius = 5
            
            uploadButtonContent.backgroundColor = UIColor.selfcOrg.withAlphaComponent(0.2)
            uploadButtonContent.setTitle(uploadTitle, for: .normal)
            uploadButtonContent.setImage(UIImage(named: "uploadIcon"), for: .normal)


            uploadButtonContent.setTitleColor(.gray, for: .normal)
            uploadButtonContent.setTitleColor(UIColor.black, for: .highlighted)
            
            
            uploadButtonContent.imageEdgeInsets = UIEdgeInsets(top: 0,left: 0,bottom: 0,right: 34)
            uploadButtonContent.titleEdgeInsets = UIEdgeInsets(top: 6,left: 20,bottom: 6,right: 14)
            
            
            let buttonWidth = scrollView.frame.width - 115
            let bound = CGRect(x: 0,y: 0, width: buttonWidth, height: buttonWidth * 0.2)
            
            uploadButtonContent.createDashedLine(bound: bound, color: .selfcOrg, strokeLength: 8, gapLength: 6, width: 2)
            
            
            self.layoutIfNeeded()
        }
    }
    
    /// set up button layout
    /// - Parameter buttonsBarContent: button bar content
    private func setupButton(with buttonsBarContent: EKProperty.ButtonBarContent) {
        var buttonsBarContent = buttonsBarContent
       
        var extractcontent = buttonsBarContent.content[1]
        let action = extractcontent.action
        extractcontent.action = { [weak self] in
            self?.extractTextFieldsContent()
            action?()
        }
        buttonsBarContent.content[1] = extractcontent
        
        buttonBarView = EKButtonBarView(with: buttonsBarContent)
        buttonBarView.clipsToBounds = true
        scrollView.addSubview(buttonBarView)
        buttonBarView.expand()
        
        if(withUploadFile) {
            //buttonBarView.layout(.top, to: .bottom, of: uploadButtonContent, offset: 20)
            buttonBarView.layout(.top, to: .bottom, of: audioButton, offset: 20)
        } else {
            buttonBarView.layout(.top, to: .bottom, of: textFieldViews.last!, offset: 20)
        }
        
        buttonBarView.layoutToSuperview(.centerX)
        buttonBarView.layoutToSuperview(.width, offset: -20)
        buttonBarView.layoutToSuperview(.bottom)
        buttonBarView.layer.cornerRadius = 5
    }
    
    /// get the text from the textFields in the for
    private func extractTextFieldsContent() {
        for (content, textField) in zip(textFieldsContent, textFieldViews) {
            content.contentWrapper.text = textField.text
        }
    }
    
    
    /// Makes a specific text field the first responder
    /// - Parameter with textFieldIndex : textField inex
    public func becomeFirstResponder(with textFieldIndex: Int) {
        textFieldViews[textFieldIndex].makeFirstResponder()
    }
    
    /// change the title color
    /// - Parameter previousTraitCollection: previous trait collection
    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        titleLabel.textColor = titleContent.style.color(for: traitCollection)
    }
    
    // MARK: User Intractions
    
    // Tap Gesture
    @objc func tapGestureRecognized() {
        endEditing(true)
    }
    
    // todo: update image from database
    public func updatePreView(imageUID : String, imageExtension : String){
        
        Util.GetImageData(imageUID: imageUID, UIDExtension: imageExtension, completion: {
            data in
            if let d = data {
                self.imageView.image = UIImage(data: d)
            }else{
                print("updatePreView : thumbnail preview error !!!!")
            }
        })
    
    }
    
    public func updatePreView(image: UIImage){
        self.imageView.image = image
    }
    
    public func getPreViewImage()->Data{
        return (self.imageView.image?.jpegData(compressionQuality: 1.0))!
    }
    
    // Setup tap gesture
    private func setupTapGestureRecognizer() {
        let tapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(tapGestureRecognized)
        )
        tapGestureRecognizer.numberOfTapsRequired = 1
        addGestureRecognizer(tapGestureRecognizer)
    }
    
}









