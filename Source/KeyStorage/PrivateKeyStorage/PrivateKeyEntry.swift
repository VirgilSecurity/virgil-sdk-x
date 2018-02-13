//
//  PrivateKeyEntry.swift
//  VirgilSDK
//
//  Created by Eugen Pivovarov on 2/13/18.
//  Copyright © 2018 VirgilSecurity. All rights reserved.
//

import Foundation
import VirgilCryptoAPI

@objc(VSSPrivateKeyEntry) public class PrivateKeyEntry: NSObject {
    @objc public let privateKey: PrivateKey
    @objc public let meta: [String: String]?

    @objc public init(privateKey: PrivateKey, meta: [String: String]? = nil) {
        self.privateKey = privateKey
        self.meta = meta
    }
}
