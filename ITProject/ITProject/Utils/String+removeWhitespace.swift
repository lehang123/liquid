//
//  String+removeWhitespace.swift
//  ITProject
//
//  Created by Erya Wen on 2019/10/27.
//  Copyright © 2019 liquid. All rights reserved.
//

import Foundation

extension String {
    
    /// remove whitespaces of the string
    func removingWhitespaces() -> String {
        return components(separatedBy: .whitespaces).joined()
    }
}
