//
//  CustomFormView.swift
//  ITProject
//
//  Created by Erya Wen on 2019/9/9.
//  Copyright © 2019 liquid. All rights reserved.
//

import UIKit
import SwiftEntryKit
import Foundation

class CustomFormView: UIView {
    
    
    private let scrollViewVerticalOffset: CGFloat = 20
    
    // MARK: Props
    
    private let titleLabel = UILabel()
    private let scrollView = UIScrollView()
    private var imageView = UIImageView()
    private let textFieldsContent: [CustomTextFieldContent]
    private var textFieldViews: [CustomTextField] = []
    private var buttonBarView: EKButtonBarView!
    private var imageViewContent: UIImage?
    private(set) var uploadButtonContent = UIButton()
    private var withUploadFile = false
    
    private var imagePicker = UIImagePickerController()
    
    private let titleContent: EKProperty.LabelContent
    
    // MARK: Setup
    
    public init(with title: EKProperty.LabelContent,
                textFieldsContent: [CustomTextFieldContent],
                buttonContent: EKProperty.ButtonBarContent,
                withUploadFile: Bool? = false) {
        self.titleContent = title
        self.textFieldsContent = textFieldsContent
        self.withUploadFile = withUploadFile!
        super.init(frame: UIScreen.main.bounds)
        setupScrollView()
        setupTitleLabel()
        setupTextFields(with: textFieldsContent)
        setupUploadView()
        setupButton(with: buttonContent)
        setupTapGestureRecognizer()
        scrollView.layoutIfNeeded()
        set(.height,
            of: scrollView.contentSize.height + scrollViewVerticalOffset * 2,
            priority: .defaultHigh)
    }
    
    public init(with title: EKProperty.LabelContent,
                textFieldsContent: [CustomTextFieldContent],
                buttonContent: EKProperty.ButtonBarContent,
                imageViewContent: UIImage,
                withUploadFile: Bool? = false) {
        self.titleContent = title
        self.textFieldsContent = textFieldsContent
        self.imageViewContent = imageViewContent
        self.withUploadFile = withUploadFile!
        super.init(frame: UIScreen.main.bounds)
        setupScrollView()
        setupTitleLabel()
        setupImageView()
        setupTextFields(with: textFieldsContent)
        setupUploadView()
        setupButton(with: buttonContent)
        setupTapGestureRecognizer()
        scrollView.layoutIfNeeded()
        set(.height,
            of: scrollView.contentSize.height,
            priority: .defaultHigh)
    }
    
    
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
    
    // Setup tap gesture
    private func setupTapGestureRecognizer() {
        let tapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(tapGestureRecognized)
        )
        tapGestureRecognizer.numberOfTapsRequired = 1
        addGestureRecognizer(tapGestureRecognizer)
    }
    
    private func setupScrollView() {
        addSubview(scrollView)
        scrollView.layoutToSuperview(axis: .horizontally, offset: 20)
        scrollView.layoutToSuperview(axis: .vertically, offset: scrollViewVerticalOffset)
        scrollView.layoutToSuperview(.width, .height, offset: -scrollViewVerticalOffset * 2)
    }
    
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
    
    private func setupTitleLabel() {
        scrollView.addSubview(titleLabel)
        titleLabel.layoutToSuperview(.top, .width)
        titleLabel.layoutToSuperview(axis: .horizontally)
        titleLabel.forceContentWrap(.vertically)
        titleLabel.content = titleContent
    }
    
    private func setupUploadView() {
        scrollView.addSubview(uploadButtonContent)
        uploadButtonContent.layoutToSuperview(.centerX)
        uploadButtonContent.layout(.top, to: .bottom, of: textFieldViews.last!, offset: 20)
        uploadButtonContent.layoutToSuperview(.width, offset: -40)
        uploadButtonContent.heightAnchor.constraint(equalTo: self.uploadButtonContent.widthAnchor, multiplier: 0.2).isActive = true
        uploadButtonContent.layer.cornerRadius = 5
        
        uploadButtonContent.backgroundColor = UIColor.selfcOrg.withAlphaComponent(0.2)
        uploadButtonContent.setTitle("Upload Thumbnail", for: .normal)
        uploadButtonContent.setImage(UIImage(named: "upload"), for: .normal)

        uploadButtonContent.setTitleColor(.gray, for: .normal)
        uploadButtonContent.setTitleColor(UIColor.black, for: .highlighted)
        uploadButtonContent.setImage(#imageLiteral(resourceName: "upload"), for: .normal)
        
        uploadButtonContent.imageEdgeInsets = UIEdgeInsets(top: 0,left: 0,bottom: 0,right: 34)
        uploadButtonContent.titleEdgeInsets = UIEdgeInsets(top: 6,left: 20,bottom: 6,right: 14)
        
        // TODO: fix width and height (now hard code)
        let bound = CGRect(x: 0,y: 0, width: 250, height: 50)
        
        uploadButtonContent.createDashedLine(bound: bound, color: .selfcOrg, strokeLength: 8, gapLength: 6, width: 2)
        
        
        self.layoutIfNeeded()
       
    }
    
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
            buttonBarView.layout(.top, to: .bottom, of: uploadButtonContent, offset: 20)
        } else {
            buttonBarView.layout(.top, to: .bottom, of: textFieldViews.last!, offset: 20)
        }
        
        buttonBarView.layoutToSuperview(.centerX)
        buttonBarView.layoutToSuperview(.width, offset: -20)
        buttonBarView.layoutToSuperview(.bottom)
        buttonBarView.layer.cornerRadius = 5
    }
    
    private func extractTextFieldsContent() {
        for (content, textField) in zip(textFieldsContent, textFieldViews) {
            content.contentWrapper.text = textField.text
        }
    }
    
    
    /** Makes a specific text field the first responder */
    public func becomeFirstResponder(with textFieldIndex: Int) {
        textFieldViews[textFieldIndex].makeFirstResponder()
    }
    
    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        titleLabel.textColor = titleContent.style.color(for: traitCollection)
    }
    
    // MARK: User Intractions
    
    // Tap Gesture
    @objc func tapGestureRecognized() {
        endEditing(true)
    }
    
    // todo: update image from database
    public func resetImage(uiname : String){
        imageView.image = UIImage(named: uiname)
    }
    
}









