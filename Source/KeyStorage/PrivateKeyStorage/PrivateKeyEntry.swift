//
//  PrivateKeyEntry.swift
//  VirgilSDK
//
//  Created by Eugen Pivovarov on 2/13/18.
//  Copyright © 2018 VirgilSecurity. All rights reserved.
//

import Foundation
import VirgilCryptoAPI

/// Class for aggregating PrivateKey and meta info
@objc(VSSPrivateKeyEntry) open class PrivateKeyEntry: NSObject {
    /// PrivateKey
    @objc public let privateKey: PrivateKey
    /// Meta info
    @objc public let meta: [String: String]?

    /// Initializer
    ///
    /// - Parameters:
    ///   - privateKey: PrivateKey
    ///   - meta: Meta info
    @objc public init(privateKey: PrivateKey, meta: [String: String]? = nil) {
        self.privateKey = privateKey
        self.meta = meta
    }
}
