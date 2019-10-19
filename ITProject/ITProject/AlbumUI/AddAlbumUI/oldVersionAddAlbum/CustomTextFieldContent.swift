//
//  CustomTextFieldContent.swift
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

public struct CustomTextFieldContent {
    
    // NOTE: Intentionally a reference type
    class ContentWrapper {
        var text = ""
    }
    
    public var keyboardType: UIKeyboardType
    public var isSecure: Bool
    public var leadingImage: UIImage!
    public var placeholder: EKProperty.LabelContent
    public var textStyle: EKProperty.LabelStyle
    public var tintColor: EKColor!
    public var displayMode: EKAttributes.DisplayMode
    public var bottomBorderColor: EKColor
    public var accessibilityIdentifier: String?
    let contentWrapper = ContentWrapper()
    public var textContent: String {
        set {
            contentWrapper.text = newValue
        }
        get {
            return contentWrapper.text
        }
    }
    
    /// initial text field content
    /// - Parameter keyboardType: keyboard type
    /// - Parameter placeholder: placeholder
    /// - Parameter tintColor: placeholder tint color
    /// - Parameter displayMode: textfield display style
    /// - Parameter textStyle: text style
    /// - Parameter isSecure: if it is secure
    /// - Parameter leadingImage: textfield image
    /// - Parameter bottomBorderColor: bottom border color
    /// - Parameter accessibilityIdentifier: accessibility identifier
    public init(keyboardType: UIKeyboardType = .default,
                placeholder: EKProperty.LabelContent,
                tintColor: EKColor? = nil,
                displayMode: EKAttributes.DisplayMode = .inferred,
                textStyle: EKProperty.LabelStyle,
                isSecure: Bool = false,
                leadingImage: UIImage? = nil,
                bottomBorderColor: EKColor = .clear,
                accessibilityIdentifier: String? = nil) {
        self.keyboardType = keyboardType
        self.placeholder = placeholder
        self.textStyle = textStyle
        self.tintColor = tintColor
        self.displayMode = displayMode
        self.isSecure = isSecure
        self.leadingImage = leadingImage
        self.bottomBorderColor = bottomBorderColor
        self.accessibilityIdentifier = accessibilityIdentifier
    }
    
    /// get tint color
    /// - Parameter traitCollection: trait collection
    public func tintColor(for traitCollection: UITraitCollection) -> UIColor? {
        return tintColor?.color(for: traitCollection, mode: displayMode)
    }
    
    /// bottom border color
    /// - Parameter traitCollection: trait collection
    public func bottomBorderColor(for traitCollection: UITraitCollection) -> UIColor? {
        return bottomBorderColor.color(for: traitCollection, mode: displayMode)
    }
    
}