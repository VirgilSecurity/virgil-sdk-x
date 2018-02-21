//
//  VSS007_KeyStorageiOSSpecificTests.swift
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 11/4/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

import Foundation
import VirgilSDK
import XCTest
import VirgilCryptoApiImpl

class VSS007_KeyStorageiOSSpecificTests: XCTestCase {
    private var crypto: VirgilCrypto!
    private var storage: KeyStorage!
    private let numberOfKeys = 1
    
    // MARK: Setup
    override func setUp() {
        super.setUp()
        
        self.crypto = VirgilCrypto()
        self.storage = KeyStorage()
    }
    
    override func tearDown() {
        self.crypto = nil
        self.storage = nil
        
        super.tearDown()
    }
    
    func test001_AddMultiple() {
        var keyEntries = Array<KeyEntry>()
        for _ in 0..<self.numberOfKeys {
            let keyPair = try! self.crypto.generateKeyPair()
            
            let privateKeyRawData = try! self.crypto.exportPrivateKey(keyPair.privateKey, password: nil)
            let privateKeyName = UUID().uuidString
            
            keyEntries.append(KeyEntry(name: privateKeyName, value: privateKeyRawData))
        }
        
        try! self.storage.storeKeyEntries(keyEntries)
        
        for entry in keyEntries {
            let loadedEntry = try! self.storage.loadKeyEntry(withName: entry.name)
            
            XCTAssert(loadedEntry.name == entry.name)
            XCTAssert(loadedEntry.value == entry.value)
        }
    }

    func test002_DeleteMultiple() {
        var names = Array<String>()
        for _ in 0..<self.numberOfKeys {
            let keyPair = try! self.crypto.generateKeyPair()
            
            let privateKeyRawData = try! self.crypto.exportPrivateKey(keyPair.privateKey, password: nil)
            let privateKeyName = UUID().uuidString
            names.append(privateKeyName)
            
            let keyEntry = KeyEntry(name: privateKeyName, value: privateKeyRawData)
            
            try! self.storage.store(keyEntry)
        }
        
        try! self.storage.deleteKeyEntries(withNames: names)
        
        for name in names {
            var errorWasThrown = false
            do {
                try self.storage.loadKeyEntry(withName: name)
            }
            catch {
                errorWasThrown = true
            }
            
            XCTAssert(errorWasThrown)
        }
    }
    
    func test003_GetAllKeys() {
        let keys0 = try! self.storage.getAllKeys()
        
        for _ in 0..<self.numberOfKeys {
            let keyPair = try! self.crypto.generateKeyPair()
            
            let privateKeyRawData = try! self.crypto.exportPrivateKey(keyPair.privateKey, password: nil)
            let privateKeyName = UUID().uuidString
            
            let keyEntry = KeyEntry(name: privateKeyName, value: privateKeyRawData)
            
            try! self.storage.store(keyEntry)
        }
        
        let keys1 = try! self.storage.getAllKeys()
        
        XCTAssert(keys1.count == keys0.count + self.numberOfKeys)
        
        for (k1, k2) in zip(keys0, Array(keys1.dropLast(self.numberOfKeys))) {
            XCTAssert(k1.name == k2.name)
            XCTAssert(k1.value == k2.value)
        }
    }
    
    func test004_GetAllKeysAttrs() {
        let keys0 = try! self.storage.getAllKeysAttrs()
        
        var keysInfo = Array<(String, Date)>()
        for _ in 0..<self.numberOfKeys {
            let keyPair = try! self.crypto.generateKeyPair()
            
            let privateKeyRawData = try! self.crypto.exportPrivateKey(keyPair.privateKey, password: nil)
            let privateKeyName = UUID().uuidString
            
            keysInfo.append((privateKeyName, Date()))
            
            let keyEntry = KeyEntry(name: privateKeyName, value: privateKeyRawData)
            
            try! self.storage.store(keyEntry)
        }
        
        let keys1 = try! self.storage.getAllKeysAttrs()
        
        XCTAssert(keys1.count == keys0.count + keysInfo.count)
        
        let newKeysAttrs = keys1
            .filter({ !keys0.map({ $0.name }).contains($0.name) })
            .sorted(by: { $0.creationDate < $1.creationDate })
        XCTAssert(newKeysAttrs.count == keysInfo.count)
        
        let eps: TimeInterval = 1
        for elem in zip(newKeysAttrs, keysInfo) {
            XCTAssert(elem.0.name == elem.1.0)
            
            let diff = abs(elem.0.creationDate.timeIntervalSince1970 - elem.1.1.timeIntervalSince1970)
            XCTAssert(diff < eps)
        }
    }
    
    func test005_Reset() {
        var keyEntries = Array<KeyEntry>()
        for _ in 0..<self.numberOfKeys {
            let keyPair = try! self.crypto.generateKeyPair()
            
            let privateKeyRawData = try! self.crypto.exportPrivateKey(keyPair.privateKey, password: nil)
            let privateKeyName = UUID().uuidString
            
            keyEntries.append(KeyEntry(name: privateKeyName, value: privateKeyRawData))
        }
        
        try! self.storage.storeKeyEntries(keyEntries)
        
        XCTAssert((try! self.storage.getAllKeysAttrs()).count != 0)
        
        try! self.storage.reset()
        
        XCTAssert((try! self.storage.getAllKeysAttrs()).count == 0)
    }
}
