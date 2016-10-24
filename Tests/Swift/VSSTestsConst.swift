//
//  VSSTestsConst.swift
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 10/24/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

import Foundation

class VSSTestsConst {
    var applicationToken: String {
        return ProcessInfo.processInfo.environment["kApplicationToken"]!
    }
    
    var applicationPublicKeyBase64: String {
        return ProcessInfo.processInfo.environment["kApplicationPublicKeyBase64"]!
    }
    
    var applicationPrivateKeyBase64: String {
        return ProcessInfo.processInfo.environment["kApplicationPrivateKeyBase64"]!
    }
    
    var applicationPrivateKeyPassword: String {
        return ProcessInfo.processInfo.environment["kApplicationPrivateKeyPassword"]!
    }
    
    var applicationIdentityType: String {
        return ProcessInfo.processInfo.environment["kApplicationIdentityType"]!
    }
    
    var applicationId: String {
        return ProcessInfo.processInfo.environment["kApplicationId"]!
    }
}
