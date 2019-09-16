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
    
    public typealias Action = () -> ()
    
    /** title Text String */
    public let titleText: String

    /** okButton Text String **/
    public let textFields: [CustomTextFieldContent]
    
    /** okButton Text String **/
    public let okButtonText: String

    /** okButton Text String **/
    public let cancelButtonText: String
    
    public var okAction: Action?
    
    public var cancelAction: Action?
    
    public let formType: FormType


    public init(titleText: String,
                textFields: [CustomTextFieldContent],
                okButtonText: String,
                okAction: @escaping Action = {},
                cancelButtonText: String,
                cancelAction: @escaping Action = {},
                formType: FormType
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
