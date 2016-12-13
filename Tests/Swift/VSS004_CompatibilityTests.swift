//
//  VSS004_CompatibilityTests.swift
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 10/17/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

import Foundation
import VirgilSDK
import XCTest

class VSS004_CompatibilityTests: XCTestCase {
    private var utils: VSSTestUtils!
    private var crypto: VSSCrypto!
    private var testsDict: Dictionary<String, Any>!
    
    // MARK: Setup
    
    override func setUp() {
        super.setUp()
        
        self.crypto = VSSCrypto()
        self.utils = VSSTestUtils(crypto: self.crypto, consts: VSSTestsConst())
        
        let testFileURL = Bundle(for: type(of: self)).url(forResource: "sdk_compatibility_data", withExtension: "json")!
        let testFileData = try! Data(contentsOf: testFileURL)
        
        self.testsDict = try! JSONSerialization.jsonObject(with: testFileData, options: JSONSerialization.ReadingOptions.init(rawValue: 0)) as! Dictionary<String, Any>
    }
    
    override func tearDown() {
        self.utils = nil
        self.crypto = nil
        
        super.tearDown()
    }
    
    // MARK: Tests
    
    func test001_CheckNumberOfTestsInJSON() {
        XCTAssert(self.testsDict.count == 6)
    }
    
    func test002_DecryptFromSingleRecipient_ShouldDecrypt() {
        let dict = self.testsDict["encrypt_single_recipient"] as! Dictionary<String, String>
        
        let privateKeyStr = dict["private_key"]!
        let privateKeyData = Data(base64Encoded: privateKeyStr)!
        
        let privateKey = self.crypto.importPrivateKey(from: privateKeyData)!
        
        let originalDataStr = dict["original_data"]!
        
        let cipherDataStr = dict["cipher_data"]!
        let cipherData = Data(base64Encoded: cipherDataStr)!
        
        let decryptedData = try! self.crypto.decrypt(cipherData, with: privateKey)
        let decryptedDataStr = decryptedData.base64EncodedString()
        
        XCTAssert(decryptedDataStr == originalDataStr)
    }
    
    func test003_DecryptFromMultipleRecipients_ShouldDecypt() {
        let dict = self.testsDict["encrypt_multiple_recipients"] as! Dictionary<String, Any>
        
        var privateKeys = Array<VSSPrivateKey>()
        
        for privateKeyStr in dict["private_keys"] as! Array<String> {
            let privateKeyData = Data(base64Encoded: privateKeyStr)!
            
            let privateKey = self.crypto.importPrivateKey(from: privateKeyData)!
            
            privateKeys.append(privateKey)
        }
        
        XCTAssert(privateKeys.count > 0)
        
        let originalDataStr = dict["original_data"] as! String
        
        let cipherDataStr = dict["cipher_data"] as! String
        let cipherData = Data(base64Encoded: cipherDataStr)!
        
        for privateKey in privateKeys {
            let decryptedData = try! self.crypto.decrypt(cipherData, with: privateKey)
            let decrypteDataStr = decryptedData.base64EncodedString()
            
            XCTAssert(decrypteDataStr == originalDataStr)
        }
    }
    
    func test004_DecryptAndVerifySingleRecipient_ShouldDecryptAndVerify() {
        let dict = self.testsDict["sign_then_encrypt_single_recipient"] as! Dictionary<String, String>
        
        let privateKeyStr = dict["private_key"]!
        let privateKeyData = Data(base64Encoded: privateKeyStr)!
        
        let privateKey = self.crypto.importPrivateKey(from: privateKeyData)!
        
        let publicKey = self.crypto.extractPublicKey(from: privateKey)
        
        let originalDataStr = dict["original_data"]!
        let originalData = Data(base64Encoded: originalDataStr)!
        let originalStr = String(data: originalData, encoding: .utf8)!
        
        let cipherDataStr = dict["cipher_data"]!
        let cipherData = Data(base64Encoded: cipherDataStr)!
        
        let decryptedData = try! self.crypto.decryptAndVerify(cipherData, with: privateKey, using: publicKey)
        
        let decryptedStr = String(data: decryptedData, encoding: .utf8)!
        
        XCTAssert(originalStr == decryptedStr)
    }
    
    func test005_DecryptAndVerifyMultipleRecipients_ShouldDecryptAndVerify() {
        let dict = self.testsDict["sign_then_encrypt_multiple_recipients"] as! Dictionary<String, Any>
        
        var privateKeys = Array<VSSPrivateKey>()
        
        for privateKeyStr in dict["private_keys"] as! Array<String> {
            let privateKeyData = Data(base64Encoded: privateKeyStr)!
            
            let privateKey = self.crypto.importPrivateKey(from: privateKeyData, withPassword: nil)!
            
            privateKeys.append(privateKey)
        }
        
        XCTAssert(privateKeys.count > 0)
        
        let originalDataStr = dict["original_data"] as! String
        
        let cipherDataStr = dict["cipher_data"] as! String
        let cipherData = Data(base64Encoded: cipherDataStr)!
        
        let signerPublicKey = self.crypto.extractPublicKey(from: privateKeys[0])
        
        for privateKey in privateKeys {
            let decryptedData = try! self.crypto.decryptAndVerify(cipherData, with: privateKey, using: signerPublicKey)
            let decrypteDataStr = decryptedData.base64EncodedString()
            
            XCTAssert(decrypteDataStr == originalDataStr)
        }
    }
    
    func test006_GenerateSignature_ShouldBeEqual() {
        let dict = self.testsDict["generate_signature"] as! Dictionary<String, String>
        
        let privateKeyStr = dict["private_key"]!
        let privateKeyData = Data(base64Encoded: privateKeyStr)!
        
        let privateKey = self.crypto.importPrivateKey(from: privateKeyData, withPassword: nil)!

        let originalDataStr = dict["original_data"]!
        let originalData = Data(base64Encoded: originalDataStr)!
        
        let signature = try! self.crypto.generateSignature(for: originalData, with: privateKey)
        let signatureStr = signature.base64EncodedString()
        
        let originalSignatureStr = dict["signature"]
        
        XCTAssert(originalSignatureStr == signatureStr)
    }
    
    func test007_ExportSignableData_ShouldBeEqual() {
        let dict = self.testsDict["export_signable_request"] as! Dictionary<String, String>

        let exportedRequest = dict["exported_request"]!
        
        let request = VSSCreateCardRequest(data: exportedRequest)!
        
        let fingerprint = self.crypto.calculateFingerprint(for: request.snapshot)
        
        let creatorPublicKey = self.crypto.importPublicKey(from: request.snapshotModel.publicKeyData)!
        
        try! self.crypto.verifyData(fingerprint.value, withSignature: request.signatures[fingerprint.hexValue]!, using: creatorPublicKey)
    }
}
