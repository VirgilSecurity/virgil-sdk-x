//
//  PrivateKeyStorage.swift
//  VirgilSDK
//
//  Created by Eugen Pivovarov on 2/13/18.
//  Copyright © 2018 VirgilSecurity. All rights reserved.
//

import Foundation
import VirgilCryptoAPI

/// Class responsible for storing Private Keys
@objc(VSSPrivateKeyStorage) public class PrivateKeyStorage: NSObject {
    /// Instance for storing, loading, deleting KeyEntries
    @objc public let keyStorage: KeyStorage
    /// PrivateKeyExporter implementation instance for import/export PrivateKey
    @objc public let privateKeyExporter: PrivateKeyExporter

    /// PrivateKeyStorage initializer
    ///
    /// - Parameters:
    ///   - privateKeyExporter: PrivateKeyExporter to use it for import/export stored Private Keys
    ///   - keyStorage: keychain key storage
    @objc public init(privateKeyExporter: PrivateKeyExporter, keyStorage: KeyStorage = KeyStorage()) {
        self.privateKeyExporter = privateKeyExporter
        self.keyStorage = keyStorage

        super.init()
    }

    /// Stores Private Key with meta
    ///
    /// - Parameters:
    ///   - privateKey: PrivateKey to store
    ///   - name: identifier for loading key back
    ///   - meta: Dictionary with any meta data
    /// - Throws: NSError if needed
    @objc public func store(privateKey: PrivateKey, name: String, meta: [String: String]?) throws {
        let privateKeyInstance = try self.privateKeyExporter.exportPrivateKey(privateKey: privateKey)
        let keyEntry = KeyEntry(name: name, value: privateKeyInstance, meta: meta)

        try self.keyStorage.store(keyEntry)
    }

    /// Loads `PrivateKeyEntry` with imported Private Key and meta
    ///
    /// - Parameter name: stored entry name
    /// - Returns: `PrivateKeyEntry` with imported Private Key and meta
    /// - Throws: NSError if needed
    @objc public func load(withName name: String) throws -> PrivateKeyEntry {
        let keyEntry = try self.keyStorage.loadKeyEntry(withName: name)
        let privateKey = try self.privateKeyExporter.importPrivateKey(from: keyEntry.value)
        let meta = keyEntry.meta

        return PrivateKeyEntry(privateKey: privateKey, meta: meta)
    }

    /// Checks whether key entry with given name exists
    ///
    /// - Parameter name: stored entry name
    /// - Returns: true if entry with this name exists, false otherwise
    @objc public func exists(withName name: String) -> Bool {
        return self.keyStorage.existsKeyEntry(withName: name)
    }

    /// Removes key entry with given name
    ///
    /// - Parameter name: key entry name to delete
    /// - Throws: NSError if needed
    @objc public func delete(withName name: String) throws {
        try self.keyStorage.deleteKeyEntry(withName: name)
    }
}
