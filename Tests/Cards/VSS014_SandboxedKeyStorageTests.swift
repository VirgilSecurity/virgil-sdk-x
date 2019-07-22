//
// Copyright (C) 2015-2019 Virgil Security Inc.
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

import VirgilSDK
import XCTest

class VSS014_SandboxedKeychainStorageTests: XCTestCase {
    private var storage: KeychainStorage!
    
    // MARK: Setup
    override func setUp() {
        super.setUp()
        
        let storageParams = try! KeychainStorageParams.makeKeychainStorageParams(appName: "test")
        
        self.storage = KeychainStorage(storageParams: storageParams)
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    // MARK: Tests
    func test001_StoreEntry() {
        let identity1 = NSUUID().uuidString
        let identity2 = NSUUID().uuidString
        
        let data1 = NSUUID().uuidString.data(using: .utf8)!
        let data2 = NSUUID().uuidString.data(using: .utf8)!
        let name = NSUUID().uuidString
        
        let storage1 = SandboxedKeychainStorage(identity: identity1, prefix: nil, keychainStorage: self.storage)
        let storage2 = SandboxedKeychainStorage(identity: identity2, prefix: nil, keychainStorage: self.storage)
        
        let keychainEntry1 = try! storage1.store(data: data1, withName: name, meta: nil)
        let keychainEntry2 = try! storage2.store(data: data2, withName: name, meta: nil)
        
        XCTAssert(keychainEntry1.name == name)
        XCTAssert(keychainEntry1.data == data1)
        let eps: TimeInterval = 1
        let date = Date()
        XCTAssert(abs(keychainEntry1.creationDate.timeIntervalSince1970 - date.timeIntervalSince1970) < eps)
        XCTAssert(abs(keychainEntry1.modificationDate.timeIntervalSince1970 - date.timeIntervalSince1970) < eps)
        XCTAssert(keychainEntry1.meta == nil)
        
        XCTAssert(keychainEntry2.name == name)
        XCTAssert(keychainEntry2.data == data2)
        XCTAssert(abs(keychainEntry2.creationDate.timeIntervalSince1970 - date.timeIntervalSince1970) < eps)
        XCTAssert(abs(keychainEntry2.modificationDate.timeIntervalSince1970 - date.timeIntervalSince1970) < eps)
        XCTAssert(keychainEntry2.meta == nil)
    }
    
    func test002_RetrieveEntry() {
        let identity1 = NSUUID().uuidString
        let identity2 = NSUUID().uuidString
        
        let data1 = NSUUID().uuidString.data(using: .utf8)!
        let data2 = NSUUID().uuidString.data(using: .utf8)!
        let name = NSUUID().uuidString
        
        let storage1 = SandboxedKeychainStorage(identity: identity1, prefix: nil, keychainStorage: self.storage)
        let storage2 = SandboxedKeychainStorage(identity: identity2, prefix: nil, keychainStorage: self.storage)
        
        _ = try! storage1.store(data: data1, withName: name, meta: nil)
        _ = try! storage2.store(data: data2, withName: name, meta: nil)
        
        let keychainEntry1 = try! storage1.retrieveEntry(withName: name)
        let keychainEntry2 = try! storage2.retrieveEntry(withName: name)
        
        XCTAssert(keychainEntry1.name == name)
        XCTAssert(keychainEntry1.data == data1)
        let eps: TimeInterval = 1
        let date = Date()
        XCTAssert(abs(keychainEntry1.creationDate.timeIntervalSince1970 - date.timeIntervalSince1970) < eps)
        XCTAssert(abs(keychainEntry1.modificationDate.timeIntervalSince1970 - date.timeIntervalSince1970) < eps)
        XCTAssert(keychainEntry1.meta == nil)
        
        XCTAssert(keychainEntry2.name == name)
        XCTAssert(keychainEntry2.data == data2)
        XCTAssert(abs(keychainEntry2.creationDate.timeIntervalSince1970 - date.timeIntervalSince1970) < eps)
        XCTAssert(abs(keychainEntry2.modificationDate.timeIntervalSince1970 - date.timeIntervalSince1970) < eps)
        XCTAssert(keychainEntry2.meta == nil)
    }
    
    func test003_RetrieveAllEntries() {
        let identity1 = NSUUID().uuidString
        let identity2 = NSUUID().uuidString
        
        let data1 = NSUUID().uuidString.data(using: .utf8)!
        let data2 = NSUUID().uuidString.data(using: .utf8)!
        let name = NSUUID().uuidString
        
        let storage1 = SandboxedKeychainStorage(identity: identity1, prefix: nil, keychainStorage: self.storage)
        let storage2 = SandboxedKeychainStorage(identity: identity2, prefix: nil, keychainStorage: self.storage)
        
        XCTAssert(try! storage1.retrieveAllEntries().isEmpty)
        XCTAssert(try! storage2.retrieveAllEntries().isEmpty)
        
        _ = try! storage1.store(data: data1, withName: name, meta: nil)
        _ = try! storage2.store(data: data2, withName: name, meta: nil)
        
        let keychainEntries1 = try! storage1.retrieveAllEntries()
        let keychainEntries2 = try! storage2.retrieveAllEntries()
        
        XCTAssert(keychainEntries1.count == 1)
        XCTAssert(keychainEntries2.count == 1)
        
        let keychainEntry1 = keychainEntries1[0]
        let keychainEntry2 = keychainEntries2[0]
        
        XCTAssert(keychainEntry1.name == name)
        XCTAssert(keychainEntry1.data == data1)
        
        XCTAssert(keychainEntry2.name == name)
        XCTAssert(keychainEntry2.data == data2)
    }
    
    func test004_DeleteEntries() {
        let identity1 = NSUUID().uuidString
        let identity2 = NSUUID().uuidString
        
        let data1 = NSUUID().uuidString.data(using: .utf8)!
        let data2 = NSUUID().uuidString.data(using: .utf8)!
        let name = NSUUID().uuidString
        
        let storage1 = SandboxedKeychainStorage(identity: identity1, prefix: nil, keychainStorage: self.storage)
        let storage2 = SandboxedKeychainStorage(identity: identity2, prefix: nil, keychainStorage: self.storage)
        
        _ = try! storage1.store(data: data1, withName: name, meta: nil)
        _ = try! storage2.store(data: data2, withName: name, meta: nil)
        
        try! storage1.deleteEntry(withName: name)
        try! storage2.deleteEntry(withName: name)
        
        var errorWasThrown = false
        do {
            let _ = try storage1.retrieveEntry(withName: name)
        }
        catch(let error as KeychainStorageError) {
            errorWasThrown = true
            XCTAssert(error.errCode == .keychainError)
            XCTAssert(error.osStatus! == -25300)
        }
        catch {
            XCTFail()
        }
        
        XCTAssert(errorWasThrown)
        
        errorWasThrown = false
        do {
            let _ = try storage2.retrieveEntry(withName: name)
        }
        catch(let error as KeychainStorageError) {
            errorWasThrown = true
            XCTAssert(error.errCode == .keychainError)
            XCTAssert(error.osStatus! == -25300)
        }
        catch {
            XCTFail()
        }
        
        XCTAssert(errorWasThrown)
    }
}
