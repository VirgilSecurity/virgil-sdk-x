//
//  SignerType.swift
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 9/15/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

import Foundation

@objc(VSSSignerType) public enum SignerType: Int {
    case `self`
    case application
    case virgil
    case custom
    
    public init?(from string: String) {
        switch string {
        case "self": self = .self
        case "application": self = .application
        case "virgil": self = .virgil
        case "custom": self = .custom
        default:
            return nil
        }
    }
}
