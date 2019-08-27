//
//  AddAlbumTextFieldSet.swift
//  ITProject
//
//  Created by Erya Wen on 2019/8/23.
//  Copyright © 2019 liquid. All rights reserved.
//
import Foundation
import SwiftEntryKit

struct TextFieldOptionSet: OptionSet {
    let rawValue: Int
    static let albumName = TextFieldOptionSet(rawValue: 1 << 0)
    static let albumDescription = TextFieldOptionSet(rawValue: 1 << 1)
}

enum FormStyle {
    case light
    case metallic
    
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
    
    private static var displayMode: EKAttributes.DisplayMode {
        return PopUpFormWindow.displayMode
    }
    
    class func albumName(placeholderStyle: EKProperty.LabelStyle,
                     textStyle: EKProperty.LabelStyle,
                     separatorColor: EKColor,
                     style: FormStyle) -> EKProperty.TextFieldContent {
        let albumNamePlaceholder = EKProperty.LabelContent(
            text: "Album Name",
            style: placeholderStyle
        )
        return .init(keyboardType: .emailAddress,
                     placeholder: albumNamePlaceholder,
                     tintColor: style.textColor,
                     displayMode: displayMode,
                     textStyle: textStyle,
                     leadingImage: UIImage(named: "albumIcon")!.withRenderingMode(.alwaysTemplate),
                     bottomBorderColor: separatorColor,
                     accessibilityIdentifier: "albumNameTextField")
    }
    
    class func albumDescription(placeholderStyle: EKProperty.LabelStyle,
                         textStyle: EKProperty.LabelStyle,
                         separatorColor: EKColor,
                         style: FormStyle) -> EKProperty.TextFieldContent {
        let albumNamePlaceholder = EKProperty.LabelContent(
            text: "Album Description",
            style: placeholderStyle
        )
        return .init(keyboardType: .emailAddress,
                     placeholder: albumNamePlaceholder,
                     tintColor: style.textColor,
                     displayMode: displayMode,
                     textStyle: textStyle,
                     leadingImage: UIImage(named: "descriptionIcon")!.withRenderingMode(.alwaysTemplate),
                     bottomBorderColor: separatorColor,
                     accessibilityIdentifier: "albumDescriptionTextField")
    }
    

    
    class func fields(by set: TextFieldOptionSet,
                      style: FormStyle) -> [EKProperty.TextFieldContent] {
        var array: [EKProperty.TextFieldContent] = []
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

        return array
    }
    
}

