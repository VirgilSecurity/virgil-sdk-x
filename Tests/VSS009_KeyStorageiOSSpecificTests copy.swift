//
//  VSS009_KeyStorageiOSSpecificTests.swift
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 11/4/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

import Foundation
import VirgilSDK
import XCTest

class VSS009_KeyStorageiOSSpecificTests: XCTestCase {
    private var crypto: VSSCrypto!
    private var storage: VSSKeyStorage!
    private var keyEntry: VSSKeyEntry!
    private var privateKeyName: String!
    
    // MARK: Setup
    override func setUp() {
        super.setUp()
        
        self.crypto = VSSCrypto()
        self.storage = VSSKeyStorage()
        let keyPair = self.crypto.generateKeyPair()
        
        let privateKeyRawData = self.crypto.export(keyPair.privateKey, withPassword: nil)
        let privateKeyName = UUID().uuidString
        
        self.keyEntry = VSSKeyEntry(name: privateKeyName, value: privateKeyRawData)
    }
    
    override func tearDown() {
        try? self.storage.deleteKeyEntry(withName: self.keyEntry.name)
        
        self.crypto = nil
        self.storage = nil
        self.keyEntry = nil
        self.privateKeyName = nil
        
        super.tearDown()
    }

    func test001_GetAllKeys() {
        let n = 5
        
        let keys0 = try! self.storage.getAllKeys()
        
        for _ in 0..<n {
            let keyPair = self.crypto.generateKeyPair()
            
            let privateKeyRawData = self.crypto.export(keyPair.privateKey, withPassword: nil)
            let privateKeyName = UUID().uuidString
            
            let keyEntry = VSSKeyEntry(name: privateKeyName, value: privateKeyRawData)
            
            try! self.storage.store(keyEntry)
        }
        
        let keys1 = try! self.storage.getAllKeys()
        
        XCTAssert(keys1.count == keys0.count + n)
        
        for (k1, k2) in zip(keys0, Array(keys1.dropLast(n))) {
            XCTAssert(k1.name == k2.name)
            XCTAssert(k1.value == k2.value)
        }
    }
    
    func test002_GetAllKeysTags() {
        let n = 5
        
        let keys0 = try! self.storage.getAllKeysTags()
        
        for _ in 0..<n {
            let keyPair = self.crypto.generateKeyPair()
            
            let privateKeyRawData = self.crypto.export(keyPair.privateKey, withPassword: nil)
            let privateKeyName = UUID().uuidString
            
            let keyEntry = VSSKeyEntry(name: privateKeyName, value: privateKeyRawData)
            
            try! self.storage.store(keyEntry)
        }
        
        let keys1 = try! self.storage.getAllKeysTags()
        
        XCTAssert(keys1.count == keys0.count + n)
        XCTAssert(keys0 == Array(keys1.dropLast(n)))
    }
}
