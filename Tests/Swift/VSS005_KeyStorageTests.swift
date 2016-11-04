//
//  VSS005_KeyStorageTests.swift
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 11/4/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

import Foundation
import VirgilSDK
import XCTest

class VSS005_KeyStorageTests: XCTestCase {
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

    // MARK: Tests
    func test001_StoreKey() {
        try! self.storage.store(self.keyEntry)
    }
    
    func test002_StoreKeyWithDuplicateName() {
        try! self.storage.store(self.keyEntry)
    
        var errorWasThrown = false
        do {
            try self.storage.store(self.keyEntry)
        }
        catch {
            errorWasThrown = true
        }
        
        XCTAssert(errorWasThrown)
    }
    
    func test003_LoadKey() {
        try! self.storage.store(self.keyEntry)
        
        let loadedKeyEntry = try! self.storage.loadKeyEntry(withName: self.keyEntry.name)
    
        XCTAssert(loadedKeyEntry.name == self.keyEntry.name)
        XCTAssert(loadedKeyEntry.value == self.keyEntry.value)
    }
    
    func test004_ExistsKey() {
        var exists = self.storage.existsKeyEntry(withName: self.keyEntry.name)
        XCTAssert(!exists)
    
        try! self.storage.store(self.keyEntry)
    
        exists = self.storage.existsKeyEntry(withName: self.keyEntry.name)
    
        XCTAssert(exists);
    }
    
    func test005_DeleteKey() {
        try! self.storage.store(self.keyEntry)
        
        try! self.storage.deleteKeyEntry(withName: self.keyEntry.name)
    
        let exists = self.storage.existsKeyEntry(withName: self.keyEntry.name)
        
        XCTAssert(!exists);
    }
}
