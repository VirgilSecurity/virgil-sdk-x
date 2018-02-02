//
//  SignerType.swift
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 9/15/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

import Foundation

public enum SignerType: String, Codable {
    case `self`      = "self"
    case virgil      = "virgil"
    case app         = "app"
}

