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
    
    private let titleContent: EKProperty.LabelContent
    
    // MARK: Setup
    
    public init(with title: EKProperty.LabelContent,
                textFieldsContent: [CustomTextFieldContent],
                buttonContent: EKProperty.ButtonBarContent) {
        self.titleContent = title
        self.textFieldsContent = textFieldsContent
        super.init(frame: UIScreen.main.bounds)
        setupScrollView()
        setupTitleLabel()
        setupTextFields(with: textFieldsContent)
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
                imageViewContent: UIImage) {
        self.titleContent = title
        self.textFieldsContent = textFieldsContent
        self.imageViewContent = imageViewContent
        super.init(frame: UIScreen.main.bounds)
        setupImageView()
        setupScrollView()
//        //setupTitleLabel()
        setupTextFields(with: textFieldsContent)
        setupButton(with: buttonContent)
        setupTapGestureRecognizer()
        scrollView.layoutIfNeeded()
        set(.height,
            of: scrollView.contentSize.height + scrollViewVerticalOffset * 2,
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
    
    private func setupImageView(){
        scrollView.addSubview(imageView)
        imageView.layoutToSuperview(.centerX, .centerY, .width)
        imageView.contentMode = .scaleAspectFit
        imageView.layoutToSuperview(.top, offset: 10)
        imageView.heightAnchor.constraint(equalTo: self.scrollView.heightAnchor, multiplier: 0.5).isActive = true
        imageView.image = imageViewContent
       
    }
    
    private func setupScrollView() {
        addSubview(scrollView)
        scrollView.layoutToSuperview(axis: .horizontally, offset: 20)
        scrollView.layoutToSuperview(axis: .vertically, offset: scrollViewVerticalOffset)
        scrollView.layoutToSuperview(.width, .height, offset: -scrollViewVerticalOffset * 2)
    }
    
    private func setupTitleLabel() {
        scrollView.addSubview(titleLabel)
        titleLabel.layoutToSuperview(.top, .width)
        titleLabel.layoutToSuperview(axis: .horizontally)
        titleLabel.forceContentWrap(.vertically)
        titleLabel.content = titleContent
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
        buttonBarView.layout(.top, to: .bottom, of: textFieldViews.last!, offset: 20)
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
    
}








