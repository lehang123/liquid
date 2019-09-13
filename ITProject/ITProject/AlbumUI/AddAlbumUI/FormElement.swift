//
//  FormElement.swift
//  ITProject
//
//  Created by Erya Wen on 2019/9/13.
//  Copyright © 2019 liquid. All rights reserved.
//

import Foundation
import UIKit

public struct FormElement{
    public enum FormType {
        case withImageView
        case withoutImageView
    }
    
    /** title Text String */
    public let titleText: String
    
    /** okButton Text String **/
    public let okButtonText : String
    /** Image, Title, Description */
    
    /** okButton Text String **/
    public let textFields: [CustomTextFieldContent]
    
    /** okButton Text String **/
    public let cancelButtonText : String
    
    public let simpleMessage: EKSimpleMessage
    
    /** Contents of button bar */
    public let buttonBarContent: EKProperty.ButtonBarContent
    
    public init(simpleMessage: EKSimpleMessage,
                imagePosition: ImagePosition = .top,
                buttonBarContent: EKProperty.ButtonBarContent) {
        self.simpleMessage = simpleMessage
        self.imagePosition = imagePosition
        self.buttonBarContent = buttonBarContent
    }
}
