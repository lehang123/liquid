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
    /// form type option
    public enum FormType {
        case withImageView
        case withoutImageView
        case defaultForm
    }
    
    public typealias Action = () -> Void
    
    /// form title
    public let titleText: String

    /// form textFields
    public let textFields: [CustomTextFieldContent]
    
    /// upload field title
    public var uploadTitle: String
    
    /// ok button title
    public let okButtonText: String

    /// cancel button title
    public let cancelButtonText: String
    
    /// ok button action
    public var okAction: Action?
    
    /// cancel button action
    public var cancelAction: Action? = nil
    
    /// form type
    public let formType: FormType
    
    
    /// initial form element
    /// - Parameter formType: form type
    /// - Parameter titleText: form title
    /// - Parameter textFields: form textFields
    /// - Parameter uploadTitle: upload field title
    /// - Parameter cancelButtonText: cancel button title
    /// - Parameter okButtonText: ok button title
    /// - Parameter cancelAction: cancel button action
    /// - Parameter okAction: ok button action
    public init(formType: FormType,
                titleText: String,
                textFields: [CustomTextFieldContent],
                uploadTitle: String,
                cancelButtonText: String,
                okButtonText: String,
                cancelAction: @escaping Action = {},
                okAction: @escaping Action = {}
                ){
        self.titleText = titleText
        self.textFields = textFields
        self.uploadTitle = uploadTitle
        self.okButtonText = okButtonText
        self.cancelButtonText = cancelButtonText
        self.okAction = okAction
        self.cancelAction = cancelAction
        self.formType = formType
    }
}
