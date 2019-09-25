//
//  EKTextField+validation.swift
//  ITProject
//
//  Created by Erya Wen on 2019/9/9.
//  Copyright © 2019 liquid. All rights reserved.
//
//  SwiftEntryKit (Created by Daniel Huri on 5/16/18.) Extension
//  EKTextField+validation


import Foundation
import UIKit
import SwiftEntryKit

final public class CustomTextField: UIView {
    
    // MARK: - Properties
    
    static let totalHeight: CGFloat = 45
    
    private let content: CustomTextFieldContent
    private let imageView = UIImageView()
    private let textField = UITextField()
    private let separatorView = UIView()
    
    /// text in the text field
    public var text: String {
        set {
            textField.text = newValue
        }
        get {
            return textField.text ?? ""
        }
    }
    
    // MARK: - Setup
    
    /// initial text field
    /// - Parameter content: text field content
    public init(with content: CustomTextFieldContent) {
        self.content = content
        super.init(frame: UIScreen.main.bounds)
        setupImageView()
        setupTextField()
        setupSeparatorView()
        textField.accessibilityIdentifier = content.accessibilityIdentifier
    }
    
    /// initial fails
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// set up image view in a text field layout
    private func setupImageView() {
        addSubview(imageView)
        imageView.contentMode = .center
        imageView.set(.width, .height, of: CustomTextField.totalHeight)
        imageView.layoutToSuperview(.leading)
        imageView.image = content.leadingImage
        imageView.tintColor = content.tintColor.color(
            for: traitCollection,
            mode: content.displayMode
        )
    }
    
    /// set up text field inner layout
    private func setupTextField() {
        addSubview(textField)
        textField.textFieldContent = content
        textField.set(.height, of: CustomTextField.totalHeight)
        textField.layout(.leading, to: .trailing, of: imageView)
        textField.layoutToSuperview(.top, .trailing)
        imageView.layout(to: .centerY, of: textField)
        
    }
    
    /// set up text field separator layout
    private func setupSeparatorView() {
        addSubview(separatorView)
        separatorView.layout(.top, to: .bottom, of: textField)
        separatorView.set(.height, of: 1)
        separatorView.layoutToSuperview(.bottom)
        separatorView.layoutToSuperview(axis: .horizontally, offset: 10)
        separatorView.backgroundColor = content.bottomBorderColor.color(
            for: traitCollection,
            mode: content.displayMode
        )
    }
    
    /// set up first responder
    public func makeFirstResponder() {
        textField.becomeFirstResponder()
    }
    
    
    /// set up text field color
    /// - Parameter previousTraitCollection: previous trait collection
    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        separatorView.backgroundColor = content.bottomBorderColor(for: traitCollection)
        imageView.tintColor = content.tintColor(for: traitCollection)
        textField.textColor = content.textStyle.color(for: traitCollection)
        textField.placeholder = content.placeholder
    }
}


