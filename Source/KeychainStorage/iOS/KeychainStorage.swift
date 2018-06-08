//
// Copyright (C) 2015-2018 Virgil Security Inc.
//
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are
// met:
//
//     (1) Redistributions of source code must retain the above copyright
//     notice, this list of conditions and the following disclaimer.
//
//     (2) Redistributions in binary form must reproduce the above copyright
//     notice, this list of conditions and the following disclaimer in
//     the documentation and/or other materials provided with the
//     distribution.
//
//     (3) Neither the name of the copyright holder nor the names of its
//     contributors may be used to endorse or promote products derived from
//     this software without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE AUTHOR ''AS IS'' AND ANY EXPRESS OR
// IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
// WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT,
// INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
// HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
// STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING
// IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.
//
// Lead Maintainer: Virgil Security Inc. <support@virgilsecurity.com>
//

import Foundation

@objc(VSSKeychainStorageErrorCodes) public enum KeychainStorageErrorCodes: Int {
    case utf8ConvertingError = 1
    case emptyKeychainResponse = 2
    case wrongResponseType = 3
    case errorParsingKeychainResponse = 4
    case invalidAppBundle = 5
    case keychainError = 6
}

@objc(VSSKeychainStorageError) public final class KeychainStorageError: NSObject, CustomNSError {
    public static var errorDomain: String { return "VirgilSDK.KeyStorageErrorDomain" }

    public var errorCode: Int { return self.errCode.rawValue }

    @objc public let errCode: KeychainStorageErrorCodes
    public let osStatus: OSStatus?

    @objc public var osStatusNumber: NSNumber? {
        if let osStatus = self.osStatus {
            return NSNumber(integerLiteral: Int(osStatus))
        }
        else {
            return nil
        }
    }

    internal init(errCode: KeychainStorageErrorCodes, osStatus: OSStatus? = nil) {
        self.errCode = errCode
        self.osStatus = osStatus

        super.init()
    }
}

@objc(VSSKeychainStorage) open class KeychainStorage: NSObject {
    @objc public static let privateKeyIdentifierFormat = ".%@.privatekey.%@\0"
    @objc public let storageParams: KeychainStorageParams

    @objc public init(storageParams: KeychainStorageParams) {
        self.storageParams = storageParams

        super.init()
    }

    @objc open func store(data: Data, withName name: String, meta: [String: String]?) throws -> KeychainEntry {
        let tag = String(format: KeychainStorage.privateKeyIdentifierFormat, self.storageParams.appName, name)
        guard let tagData = tag.data(using: .utf8),
            let nameData = name.data(using: .utf8) else {
                throw KeychainStorageError(errCode: .utf8ConvertingError)
        }

        var query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrKeyClass as String: kSecAttrKeyClassPrivate,
            kSecAttrApplicationLabel as String: nameData,
            kSecAttrApplicationTag as String: tagData,

            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock,
            kSecAttrLabel as String: name,
            kSecAttrIsPermanent as String: true,
            kSecAttrCanEncrypt as String: true,
            kSecAttrCanDecrypt as String: false,
            kSecAttrCanDerive as String: false,
            kSecAttrCanSign as String: true,
            kSecAttrCanVerify as String: false,
            kSecAttrCanWrap as String: false,
            kSecAttrCanUnwrap as String: false,
            kSecAttrSynchronizable as String: false,

            kSecReturnData as String: true,
            kSecReturnAttributes as String: true
        ]

        // Access groups are not supported in simulator
        #if TARGET_OS_IPHONE && !TARGET_IPHONE_SIMULATOR
        if let accessGroup = self.storageParams.accessGroup {
            query[kSecAttrAccessGroup] = accessGroup
        }
        #endif

        let keyEntry = KeyEntry(name: name, value: data, meta: meta)
        let keyEntryData = NSKeyedArchiver.archivedData(withRootObject: keyEntry)

        query[kSecValueData as String] = keyEntryData

        var dataObject: AnyObject?

        let status = SecItemAdd(query as CFDictionary, &dataObject)

        let data = try KeychainStorage.validateKeychainResponse(dataObject: dataObject, status: status)

        return try KeychainStorage.parseKeychainEntry(from: data)
    }
    
    @objc open func updateEntry(withName name: String, data: Data, meta: [String: String]?) throws {
        let tag = String(format: KeychainStorage.privateKeyIdentifierFormat, self.storageParams.appName, name)
        guard let tagData = tag.data(using: .utf8),
            let nameData = name.data(using: .utf8) else {
                throw KeychainStorageError(errCode: .utf8ConvertingError)
        }
        
        var query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrKeyClass as String: kSecAttrKeyClassPrivate,
            kSecAttrApplicationLabel as String: nameData,
            kSecAttrApplicationTag as String: tagData,
        ]
        
        // Access groups are not supported in simulator
        #if TARGET_OS_IPHONE && !TARGET_IPHONE_SIMULATOR
        if let accessGroup = self.storageParams.accessGroup {
            query[kSecAttrAccessGroup] = accessGroup
        }
        #endif
        
        let keyEntry = KeyEntry(name: name, value: data, meta: meta)
        let keyEntryData = NSKeyedArchiver.archivedData(withRootObject: keyEntry)
        
        let keySpecificData: [String: Any] = [
            kSecValueData as String: keyEntryData,
        ]
        
        let status = SecItemUpdate(query as CFDictionary, keySpecificData as CFDictionary)
        
        guard status == errSecSuccess else {
            throw KeychainStorageError(errCode: .keychainError, osStatus: status)
        }
    }

    @objc open func retrieveEntry(withName name: String) throws -> KeychainEntry {
        let tag = String(format: KeychainStorage.privateKeyIdentifierFormat, self.storageParams.appName, name)
        guard let tagData = tag.data(using: .utf8),
            let nameData = name.data(using: .utf8) else {
                throw KeychainStorageError(errCode: .utf8ConvertingError)
        }

        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrKeyClass as String: kSecAttrKeyClassPrivate,
            kSecAttrApplicationLabel as String: nameData,
            kSecAttrApplicationTag as String: tagData,

            kSecReturnData as String: true,
            kSecReturnAttributes as String: true
        ]

        var dataObject: AnyObject?

        let status = SecItemCopyMatching(query as CFDictionary, &dataObject)

        let data = try KeychainStorage.validateKeychainResponse(dataObject: dataObject, status: status)

        return try KeychainStorage.parseKeychainEntry(from: data)
    }

    @objc open func retrieveAllEntries() throws -> [KeychainEntry] {
        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrKeyClass as String: kSecAttrKeyClassPrivate,

            kSecReturnData as String: true,
            kSecReturnAttributes as String: true,

            kSecMatchLimit as String: kSecMatchLimitAll
        ]

        var dataObject: AnyObject?

        let status = SecItemCopyMatching(query as CFDictionary, &dataObject)

        if status == errSecItemNotFound {
            return []
        }

        let data = try KeychainStorage.validateKeychainResponse(dataObject: dataObject, status: status)

        guard let arr = data as? [AnyObject] else {
            throw KeychainStorageError(errCode: .wrongResponseType)
        }

        return try arr.map { try KeychainStorage.parseKeychainEntry(from: $0) }
    }

    @objc open func deleteEntry(withName name: String) throws {
        let tag = String(format: KeychainStorage.privateKeyIdentifierFormat, self.storageParams.appName, name)
        guard let tagData = tag.data(using: .utf8),
            let nameData = name.data(using: .utf8) else {
                throw KeychainStorageError(errCode: .utf8ConvertingError)
        }

        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrKeyClass as String: kSecAttrKeyClassPrivate,
            kSecAttrApplicationLabel as String: nameData,
            kSecAttrApplicationTag as String: tagData
        ]

        let status = SecItemDelete(query as CFDictionary)

        guard status == errSecSuccess else {
            throw KeychainStorageError(errCode: .keychainError, osStatus: status)
        }
    }
    
    @objc open func deleteAllEntries() throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrKeyClass as String: kSecAttrKeyClassPrivate,
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        if status == errSecItemNotFound {
            return
        }
        
        guard status == errSecSuccess else {
            throw KeychainStorageError(errCode: .keychainError, osStatus: status)
        }
    }

    private static func validateKeychainResponse(dataObject: AnyObject?, status: OSStatus) throws -> AnyObject {
        guard status == errSecSuccess else {
            throw KeychainStorageError(errCode: .keychainError, osStatus: status)
        }

        guard let data = dataObject else {
            throw KeychainStorageError(errCode: .emptyKeychainResponse)
        }

        return data
    }

    private static func parseKeychainEntry(from data: AnyObject) throws -> KeychainEntry {
        guard let dict = data as? [String: Any] else {
            throw KeychainStorageError(errCode: .wrongResponseType)
        }

        guard let creationDate = dict[kSecAttrCreationDate as String] as? Date,
            let modificationDate = dict[kSecAttrModificationDate as String] as? Date,
            let rawData = dict[kSecValueData as String] as? Data,
            let storedKeyEntry = NSKeyedUnarchiver.unarchiveObject(with: rawData) as? KeyEntry else {
                throw KeychainStorageError(errCode: .errorParsingKeychainResponse)
        }

        return KeychainEntry(data: storedKeyEntry.value, name: storedKeyEntry.name,
                             meta: storedKeyEntry.meta, creationDate: creationDate, modificationDate: modificationDate)
    }
}
