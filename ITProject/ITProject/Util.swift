//
//  Util.swift
//  ITProject
//
//  Created by Gong Lehan on 9/8/19.
//  Copyright © 2019 liquid. All rights reserved.
//

import Foundation

class Util {
    
    public static var ACCOUNT_INCORRECT = "Email/Password Incorrect"
    
    public static func GenerateUDID () -> String!{
        let uuid = UUID().uuidString
        return uuid
    }
    
    
}
