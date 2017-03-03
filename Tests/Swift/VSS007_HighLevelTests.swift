//
//  VSS007_HighLevelTests.swift
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 3/3/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

import Foundation
import XCTest
import VirgilSDK

class VSS007_HighLevelTests: XCTestCase {
    private var utils: VSSTestUtils!
    private var consts: VSSTestsConst!
    private var api: VSSVirgilApi!
    
    // MARK: Setup
    
    override func setUp() {
        super.setUp()
        
        self.consts = VSSTestsConst()
        
        let context = VSSVirgilApiContext(token: self.consts.applicationToken)
        context.credentials = VSSCredentials(crypto: VSSCrypto(), appKeyData: Data(base64Encoded: self.consts.applicationPrivateKeyBase64)!, appKeyPassword: self.consts.applicationPrivateKeyPassword, appId: self.consts.applicationId)
        
        self.api = VSSVirgilApi(context: context)
        
        self.utils = VSSTestUtils(crypto: VSSCrypto(), consts: self.consts)
    }
    
    override func tearDown() {
        self.utils = nil
        self.consts = nil
        self.api = nil
        
        super.tearDown()
    }
    
    // MARK: Tests
    func testC01_CreateCard() {
        let ex = self.expectation(description: "Virgil Card should be created")
        
        let numberOfRequests = 1
        let timeout = TimeInterval(numberOfRequests * kEstimatedRequestCompletionTime)
        
        let identityValue = NSUUID().uuidString
        let identity = self.api.identities.createIdentity(withValue: identityValue, type: "test")
        let key = self.api.keys.generateKey()
        let card = try! self.api.cards.createCard(with: identity, ownerKey: key, data: nil)
        self.api.cards.publishCard(card) { (error) in
            XCTAssert(error == nil)
            
            ex.fulfill()
        }
        
        self.waitForExpectations(timeout: timeout) { error in
            guard error == nil else {
                XCTFail("Expectation failed: " + error!.localizedDescription)
                return
            }
        }
    }
}
