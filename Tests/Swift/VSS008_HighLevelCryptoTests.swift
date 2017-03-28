//
//  VSS008_HighLevelCryptoTests.swift
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 3/28/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

import Foundation
import XCTest
import VirgilSDK

class VSS008_HighLevelCryptoTests: XCTestCase {
    private var card1, card2, card3: VSSVirgilCard!
    private var key1, key2, key3: VSSVirgilKey!
    private var data: Data!
    private var str: String!
    private var api: VSSVirgilApi!
    
    // MARK: Setup
    override func setUp() {
        super.setUp()
        
        self.api = VSSVirgilApi()
        self.key1 = api.keys.generateKey()
        self.key2 = api.keys.generateKey()
        self.key3 = api.keys.generateKey()
        
        let identity1 = self.api.identities.createUserIdentity(withValue: "test1", type: "test")
        self.card1 = try! self.api.cards.createCard(with: identity1, ownerKey: self.key1)
        
        let identity2 = self.api.identities.createUserIdentity(withValue: "test2", type: "test")
        self.card2 = try! self.api.cards.createCard(with: identity2, ownerKey: self.key2)
        
        let identity3 = self.api.identities.createUserIdentity(withValue: "test3", type: "test")
        self.card3 = try! self.api.cards.createCard(with: identity3, ownerKey: self.key3)
        
        self.data = UUID().uuidString.data(using: .utf8)!
        self.str = UUID().uuidString
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testHED001_EncryptRandomData_SingleCorrectKey_ShouldDecrypt() {
        let encryptedData = try! self.card1.encrypt(self.data)
        let decryptedData = try! self.key1.decrypt(encryptedData)
        
        XCTAssert(data == decryptedData)
    }
    
    func testHED002_EncryptRandomData_SingleIncorrectKey_ShouldNotDecrypt() {
        let encryptedData = try! self.card1.encrypt(self.data)
        let decryptedData = try? self.key2.decrypt(encryptedData)
        
        XCTAssert(decryptedData == nil)
    }
    
    func testHES001_EncryptRandomString_SingleCorrectKey_ShouldDecrypt() {
        let encryptedData = try! self.card1.encrypt(self.str)
        let decryptedData = try! self.key1.decrypt(encryptedData)
        let decryptedString = String(data: decryptedData, encoding: .utf8)
        
        XCTAssert(self.str == decryptedString)
    }
    
    func testHED003_EncryptRandomData_TwoCorrectKeys_ShouldDecrypt() {
        let encryptedData = try! self.api.encrypt(self.data, for: [self.card1, self.card2])
        
        let decryptedData1 = try! self.key1.decrypt(encryptedData)
        let decryptedData2 = try! self.key2.decrypt(encryptedData)
        
        XCTAssert(self.data == decryptedData1)
        XCTAssert(self.data == decryptedData2)
    }
    
    func testHES003_EncryptRandomString_TwoCorrectKeys_ShouldDecrypt() {
        let encryptedData = try! self.api.encrypt(self.str, for: [self.card1, self.card2])
        
        let decryptedData1 = try! self.key1.decrypt(encryptedData)
        let decryptedStr1 = String(data: decryptedData1, encoding: .utf8)!
        let decryptedData2 = try! self.key2.decrypt(encryptedData)
        let decryptedStr2 = String(data: decryptedData2, encoding: .utf8)!
        
        XCTAssert(self.str == decryptedStr1)
        XCTAssert(self.str == decryptedStr2)
    }
    

    // MARK: Signatures tests
    func testHSD001_SignRandomData_CorrectKeys_ShouldValidate() {
        let signature = try! self.key1.generateSignature(for: self.data)
        try! self.card1.verify(self.data, withSignature: signature)
    }
    
    func testHSS001_SignRandomString_CorrectKeys_ShouldValidate() {
        let signature = try! self.key1.generateSignature(for: self.str)
        
        try! self.card1.verify(self.str, withSignature: signature)
    }

    func testHSD002_SignRandomData_IncorrectKeys_ShouldNotValidate() {
        let signature = try! self.key1.generateSignature(for: self.data)
        
        var errorWasThrown = false
        do {
            try self.card2.verify(self.data, withSignature: signature)
        }
        catch {
            errorWasThrown = true
        }
        XCTAssert(errorWasThrown)
    }
    
    func testHSS002_SignRandomString_IncorrectKeys_ShouldNotValidate() {
        let signature = try! self.key1.generateSignature(for: self.str)
        
        var errorWasThrown = false
        do {
            try self.card2.verify(self.str, withSignature: signature)
        }
        catch {
            errorWasThrown = true
        }
        XCTAssert(errorWasThrown)
    }
    
    func testHESD001_SignThenEncryptRandomData_CorrectKeys_ShouldDecryptValidate() {
        let signedThenEcryptedData = try! self.key1.signThenEncrypt(self.data, for: [self.card2])
        
        let decryptedThenVerifiedData = try! self.key2.decryptThenVerify(signedThenEcryptedData, from: self.card1)
        
        XCTAssert(self.data == decryptedThenVerifiedData)
    }
    
    func testHESS001_SignThenEncryptRandomString_CorrectKeys_ShouldDecryptValidate() {
        let signedThenEcryptedData = try! self.key1.signThenEncrypt(self.str, for: [self.card2])
        
        let decryptedThenVerifiedData = try! self.key2.decryptThenVerify(signedThenEcryptedData, from: self.card1)
        let decryptedThenVerifiedStr = String(data: decryptedThenVerifiedData, encoding: .utf8)!
        
        XCTAssert(self.str == decryptedThenVerifiedStr)
    }

    func testHESD002_SignThenEncryptRandomData_TwoKeys_ShouldDecryptValidate() {
        let signedThenEcryptedData = try! self.key1.signThenEncrypt(self.data, for: [self.card2])
        
        let decryptedThenVerifiedData = try! self.key2.decryptThenVerify(signedThenEcryptedData, fromOneOf: [self.card3, self.card1])
        
        XCTAssert(self.data == decryptedThenVerifiedData)
    }
    
    func testHESS002_SignThenEncryptRandomString_TwoKeys_ShouldDecryptValidate() {
        let signedThenEcryptedData = try! self.key1.signThenEncrypt(self.str, for: [self.card2])
        
        let decryptedThenVerifiedData = try! self.key2.decryptThenVerify(signedThenEcryptedData, fromOneOf: [self.card3, self.card1])
        let decryptedThenVerifiedStr = String(data: decryptedThenVerifiedData, encoding: .utf8)!
        
        XCTAssert(self.str == decryptedThenVerifiedStr)
    }

    func testHESD003_SignThenEncryptRandomData_NoSenderKeys_ShouldNotValidate() {
        let signedThenEcryptedData = try! self.key1.signThenEncrypt(self.data, for: [self.card2])
        
        var errorWasThrown = false
        do {
            try self.key2.decryptThenVerify(signedThenEcryptedData, fromOneOf: [self.card3])
        }
        catch {
            errorWasThrown = true
        }
        
        XCTAssert(errorWasThrown)
    }
    
    func testHESS003_SignThenEncryptRandomString_NoSenderKeys_ShouldNotValidate() {
        let signedThenEcryptedData = try! self.key1.signThenEncrypt(self.str, for: [self.card2])
        
        var errorWasThrown = false
        do {
            try self.key2.decryptThenVerify(signedThenEcryptedData, fromOneOf: [self.card3])
        }
        catch {
            errorWasThrown = true
        }
        
        XCTAssert(errorWasThrown)
    }
}
