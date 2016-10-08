//
//  VirgilSDKTestsSwift.swift
//  VirgilSDKTestsSwift
//
//  Created by Oleksandr Deundiak on 10/8/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

import XCTest

let kApplicationToken = <#String: Application Access Token#>
let kApplicationPublicKeyBase64 = <#String: Application Public Key#>
let kApplicationPrivateKeyBase64 = <#String: Application Private Key in base64#>
let kApplicationPrivateKeyPassword = <#String: Application Private Key password#>
let kApplicationIdentityType = String: <#Application Identity Type#>
let kApplicationId = <#String: Application Id#>

/// Each request should be done less than or equal this number of seconds.
let kEstimatedRequestCompletionTime = 5

class VSS001_ClientTests: XCTestCase {
    
    private var client: VSSClient!
    private var crypto: VSSCrypto!
    
    // MARK: Setup
    
    override func setUp() {
        super.setUp()
        
        self.client = VSSClient(applicationToken: kApplicationToken)
        self.crypto = VSSCrypto()
        self.continueAfterFailure = false
    }
    
    override func tearDown() {
        self.client = nil
        self.crypto = nil
        
        super.tearDown()
    }
    
    // MARK: Tests
    func test001_CreateCard() {
        let ex = self.expectation(description: "Virgil Card should be created")
        
        let numberOfRequests = 1
        let timeout = TimeInterval(numberOfRequests * kEstimatedRequestCompletionTime)
        
        let instantiatedCard = self.instantiateCard()
        
        self.client.createCard(instantiatedCard, completion: { (card, error) in
            guard error == nil else {
                XCTFail("Expectation failed: " + error!.localizedDescription)
                return
            }
            
            guard let createdCard = card else {
                XCTFail("Card is nil")
                return
            }
            
            XCTAssert(!createdCard.identifier!.isEmpty)
            XCTAssert(self.check(card: instantiatedCard, isEqualToCard: createdCard))
            let validator = VSSCardValidator(crypto: self.crypto)
            validator.addVerifier(withId: kApplicationId, publicKey: Data(base64Encoded: kApplicationPublicKeyBase64, options: Data.Base64DecodingOptions(rawValue: 0))!)
            
            XCTAssert(validator.validate(createdCard))
            
            ex.fulfill()
        })
        
        self.waitForExpectations(timeout: timeout, handler: { error in
            guard error == nil else {
                XCTFail("Expectation failed: " + error!.localizedDescription)
                return
            }
        })
    }
    
    // MARK: Private logic
    
    private func instantiateCard() -> VSSCard {
        let keyPair = self.crypto.generateKeyPair()
        let exportedPublicKey = self.crypto.export(keyPair.publicKey)
        
        // some random value
        let identityValue = UUID().uuidString
        let identityType = kApplicationIdentityType
        let card = VSSCard.create(withIdentity: identityValue, identityType: identityType, publicKey: exportedPublicKey)

        let privateAppKeyData = Data(base64Encoded: kApplicationPrivateKeyBase64, options: Data.Base64DecodingOptions(rawValue: 0))!
        let appPrivateKey = self.crypto.importPrivateKey(privateAppKeyData, password: kApplicationPrivateKeyPassword)!
        
        let requestSigner = VSSRequestSigner(crypto: self.crypto)

        var error: NSError?
        requestSigner.applicationSignRequest(card, with: keyPair.privateKey, error: &error)
        requestSigner.authoritySignRequest(card, appId: kApplicationId, with: appPrivateKey, error: &error)
        
        return card;
    }
    
    private func check(card card1: VSSCard, isEqualToCard card2: VSSCard) -> Bool {
        let equals = card1.snapshot == card2.snapshot
            && card1.data.identityType == card2.data.identityType
            && card1.data.identity == card2.data.identity
        
        return equals
    }
}
