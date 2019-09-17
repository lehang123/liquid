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
        case defaultForm
    }
    
    public typealias Action = () -> Void
    
    /** title Text String */
    public let titleText: String

    /** okButton Text String **/
    public let textFields: [CustomTextFieldContent]
    
    /** okButton Text String **/
    public let okButtonText: String

    /** okButton Text String **/
    public let cancelButtonText: String
    
    public var okAction: Action?
    
    public var cancelAction: Action? = nil
    
    public let formType: FormType


    public init(formType: FormType,
                titleText: String,
                textFields: [CustomTextFieldContent],
                cancelButtonText: String,
                okButtonText: String,
                cancelAction: @escaping Action = {},
                okAction: @escaping Action = {}
                ){
        self.titleText = titleText
        self.textFields = textFields
        self.okButtonText = okButtonText
        self.cancelButtonText = cancelButtonText
        self.okAction = okAction
        self.cancelAction = cancelAction
        self.formType = formType
    }
}
