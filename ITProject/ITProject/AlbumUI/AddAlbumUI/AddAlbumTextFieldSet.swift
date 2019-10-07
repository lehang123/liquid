//
//  AddAlbumTextFieldSet.swift
//  ITProject
//
//  Created by Erya Wen on 2019/8/23.
//  Copyright © 2019 liquid. All rights reserved.
//

import Foundation
import SwiftEntryKit

/// Text Field Option in pop up form
struct TextFieldOptionSet: OptionSet {
    let rawValue: Int
    static let albumName = TextFieldOptionSet(rawValue: 1 << 0)
    static let albumDescription = TextFieldOptionSet(rawValue: 1 << 1)
    static let photoDescription = TextFieldOptionSet(rawValue: 1 << 2)
}

/// Form color style
enum FormStyle {
    case light
    
    var buttonTitle: EKProperty.LabelStyle {
        return .init(
            font: MainFont.bold.with(size: 16),
            color: buttonTitleColor
        )
    }
    
    var textColor: EKColor {
        return .standardContent
    }
    
    var buttonTitleColor: EKColor {
        return .white
    }
    
    var buttonBackground: EKColor {
        return .redish
    }
    
    var placeholder: EKProperty.LabelStyle {
        let font = MainFont.light.with(size: 14)
        return .init(font: font, color: UIColor(white: 0.5, alpha: 1).ekColor)
    }
    
    var separator: EKColor {
        return UIColor(white: 0.8784, alpha: 0.6).ekColor
    }
}


final class AddAlbumUI {
    static var displayMode = EKAttributes.DisplayMode.inferred
    /// Return the pop up form display mode
    private var displayMode: EKAttributes.DisplayMode {
        return AddAlbumUI.displayMode
    }
    
    // MARK: - Setup each textField
    /// initial album name textField
    ///
    /// - Parameters:
    ///   - placeholderStyle: the placeholder appear in the albumName textfield
    ///   - textStyle: the text style include font, color
    ///   - separatorColor: the separator bottom line color
    ///   - style: textFields style
    /// - Returns: text field content
    class func albumName(placeholderStyle: EKProperty.LabelStyle,
                     textStyle: EKProperty.LabelStyle,
                     separatorColor: EKColor,
                     style: FormStyle) -> CustomTextFieldContent {
        let albumNamePlaceholder = EKProperty.LabelContent(
            text: "Album Name",
            style: placeholderStyle
        )
        return .init(keyboardType: .emailAddress,
                     placeholder: albumNamePlaceholder,
                     tintColor: style.textColor,
                     displayMode: displayMode,
                     textStyle: textStyle,
                     leadingImage: ImageAsset.album_icon.image.withRenderingMode(.alwaysTemplate),
                     bottomBorderColor: separatorColor,
                     accessibilityIdentifier: "albumNameTextField")
    }
    
    /// initial album description textField
    ///
    /// - Parameters:
    ///   - placeholderStyle: the placeholder appear in the albumDescription textfield
    ///   - textStyle: the text style include font, color
    ///   - separatorColor: the separator bottom line color
    ///   - style: textFields style
    /// - Returns: text field content
    class func albumDescription(placeholderStyle: EKProperty.LabelStyle,
                         textStyle: EKProperty.LabelStyle,
                         separatorColor: EKColor,
                         style: FormStyle) -> CustomTextFieldContent {
        let albumNamePlaceholder = EKProperty.LabelContent(
            text: "Album Description",
            style: placeholderStyle
        )
        return .init(keyboardType: .emailAddress,
                     placeholder: albumNamePlaceholder,
                     tintColor: style.textColor,
                     displayMode: displayMode,
                     textStyle: textStyle,
                     leadingImage: ImageAsset.description_icon.image.withRenderingMode(.alwaysTemplate),
                     bottomBorderColor: separatorColor,
                     accessibilityIdentifier: "albumDescriptionTextField")
    }
    
    /// initial photo description textField
    ///
    /// - Parameters:
    ///   - placeholderStyle: the placeholder appear in the photoDescription textfield
    ///   - textStyle: the text style include font, color
    ///   - separatorColor: the separator bottom line color
    ///   - style: textFields style
    /// - Returns: text field content
    class func photoDescription(placeholderStyle: EKProperty.LabelStyle,
                                textStyle: EKProperty.LabelStyle,
                                separatorColor: EKColor,
                                style: FormStyle) -> CustomTextFieldContent {
        let albumNamePlaceholder = EKProperty.LabelContent(
            text: "Photo Description",
            style: placeholderStyle
        )
        return .init(keyboardType: .emailAddress,
                     placeholder: albumNamePlaceholder,
                     tintColor: style.textColor,
                     displayMode: displayMode,
                     textStyle: textStyle,
                     leadingImage: ImageAsset.description_icon.image.withRenderingMode(.alwaysTemplate),
                     bottomBorderColor: separatorColor,
                     accessibilityIdentifier: "photoDescriptionTextField")
    }
    

    // MARK: - Setup textField content
    /// initial textField
    /// - Parameter set: text field options
    /// - Parameter style: text field style
    class func fields(by set: TextFieldOptionSet,
                      style: FormStyle) -> [CustomTextFieldContent] {
        var array: [CustomTextFieldContent] = []
        let placeholderStyle = style.placeholder
        let textStyle = EKProperty.LabelStyle(
            font: MainFont.light.with(size: 14),
            color: .standardContent,
            displayMode: displayMode
        )
        let separatorColor = style.separator
        if set.contains(.albumName) {
            array.append(albumName(placeholderStyle: placeholderStyle,
                                  textStyle: textStyle,
                                  separatorColor: separatorColor,
                                  style: style))
        }
        
        if set.contains(.albumDescription) {
            array.append(albumDescription(placeholderStyle: placeholderStyle,
                                   textStyle: textStyle,
                                   separatorColor: separatorColor,
                                   style: style))
        }
        
        if set.contains(.photoDescription) {
            array.append(photoDescription(placeholderStyle: placeholderStyle,
                                          textStyle: textStyle,
                                          separatorColor: separatorColor,
                                          style: style))
        }

        return array
    }
    
}

