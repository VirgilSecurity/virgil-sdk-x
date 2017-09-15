//
//  Serializable.swift
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 9/15/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

import Foundation

@objc(VSSSerializable) public protocol Serializable {
    func serialize() -> Any
}
