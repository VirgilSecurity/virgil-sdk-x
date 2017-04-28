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
    private var mailinator: Mailinator!
    
    // MARK: Setup
    override func setUp() {
        super.setUp()
        
        self.consts = VSSTestsConst()
        
        let appPrivateKeyData = Data(base64Encoded: self.consts.applicationPrivateKeyBase64)!
        let credentials = VSSCredentials(appKeyData: appPrivateKeyData, appKeyPassword: self.consts.applicationPrivateKeyPassword, appId: self.consts.applicationId)
        
        let crypto = VSSCrypto()
        
        let context = VSSVirgilApiContext(crypto: VSSCrypto(), token: self.consts.applicationToken, credentials: credentials, cardVerifiers: nil)
        let validator = VSSCardValidator(crypto: crypto)
        let privateKey = crypto.importPrivateKey(from: Data(base64Encoded: self.consts.applicationPrivateKeyBase64)!, withPassword: self.consts.applicationPrivateKeyPassword)!
        let publicKey = crypto.extractPublicKey(from: privateKey)
        let publicKeyData = crypto.export(publicKey)
        XCTAssert(validator.addVerifier(withId: self.consts.applicationId, publicKeyData: publicKeyData))
        // FIXME
        validator.useVirgilServiceVerifiers = false
        let config = VSSServiceConfig(token: self.consts.applicationToken)
        config.cardValidator = validator
        
//        config.cardsServiceURL = self.consts.cardsServiceURL
//        config.cardsServiceROURL = self.consts.cardsServiceROURL
//        config.identityServiceURL = self.consts.identityServiceURL
//        config.registrationAuthorityURL = self.consts.registrationAuthorityURL
        
        let client = VSSClient(serviceConfig: config)
        context.client = client
        
        self.api = VSSVirgilApi(context: context)
        
        self.utils = VSSTestUtils(crypto: VSSCrypto(), consts: self.consts)
        
        self.mailinator = Mailinator(applicationToken: self.consts.mailinatorToken, serviceUrl: URL(string: "https://api.mailinator.com/api/")!)
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
        let identity = self.api.identities.createUserIdentity(withValue: identityValue, type: "test")
        let key = self.api.keys.generateKey()
        let card = try! self.api.cards.createCard(with: identity, ownerKey: key)
        self.api.cards.publish(card) { (error) in
            XCTAssert(error == nil)
            XCTAssert(self.utils.checkHighLevelCardIsValid(card: card))
            
            ex.fulfill()
        }
        
        self.waitForExpectations(timeout: timeout) { error in
            guard error == nil else {
                XCTFail("Expectation failed: " + error!.localizedDescription)
                return
            }
        }
    }
    
    func testC02_CreateCardWithData() {
        let ex = self.expectation(description: "Virgil Card with data should be created")
        
        let numberOfRequests = 1
        let timeout = TimeInterval(numberOfRequests * kEstimatedRequestCompletionTime)
        
        let identityValue = NSUUID().uuidString
        let identity = self.api.identities.createUserIdentity(withValue: identityValue, type: "test")
        let key = self.api.keys.generateKey()
        
        let card = try! self.api.cards.createCard(with: identity, ownerKey: key, customFields: ["custom_key1": "custom_field1", "custom_key2": "custom_field2"])
        self.api.cards.publish(card) { (error) in
            XCTAssert(error == nil)
            XCTAssert(self.utils.checkHighLevelCardIsValid(card: card))
            
            ex.fulfill()
        }
        
        self.waitForExpectations(timeout: timeout) { error in
            guard error == nil else {
                XCTFail("Expectation failed: " + error!.localizedDescription)
                return
            }
        }
    }
    
    func testC03_SearchCards() {
        let ex = self.expectation(description: "Virgil Card should be created. Search should return 1 card which is equal to created card");
        
        let numberOfRequests = 2
        let timeout = TimeInterval(numberOfRequests * kEstimatedRequestCompletionTime)
        
        let identityValue = NSUUID().uuidString
        let identity = self.api.identities.createUserIdentity(withValue: identityValue, type: "test")
        let key = self.api.keys.generateKey()
        
        let card = try! self.api.cards.createCard(with: identity, ownerKey: key)
        self.api.cards.publish(card) { (error) in
            sleep(3)
            self.api.cards.searchCards(withIdentities: [identityValue]) { cards, error in
                XCTAssert(error == nil)
                XCTAssert(cards != nil)
                XCTAssert(cards!.count == 1)
                
                XCTAssert(self.utils.check(card: card, isEqualToCard: cards![0]))
                
                ex.fulfill()
            }
        }
        
        self.waitForExpectations(timeout: timeout) { error in
            guard error == nil else {
                XCTFail("Expectation failed: " + error!.localizedDescription)
                return
            }
        }
    }
    
    func testC04_GetCard() {
        let ex = self.expectation(description: "Virgil Card should be created. Get card request should return 1 card which is equal to created card");
        
        let numberOfRequests = 2
        let timeout = TimeInterval(numberOfRequests * kEstimatedRequestCompletionTime)
        
        let identityValue = NSUUID().uuidString
        let identity = self.api.identities.createUserIdentity(withValue: identityValue, type: "test")
        let key = self.api.keys.generateKey()
        
        let card = try! self.api.cards.createCard(with: identity, ownerKey: key)
        self.api.cards.publish(card) { (error) in
            sleep(3)
            
            self.api.cards.getCard(withId: card.identifier) { foundCard, error in
                XCTAssert(error == nil)
                XCTAssert(foundCard != nil)
                
                XCTAssert(self.utils.check(card: card, isEqualToCard: foundCard!))
                
                ex.fulfill()
            }
        }
        
        self.waitForExpectations(timeout: timeout) { error in
            guard error == nil else {
                XCTFail("Expectation failed: " + error!.localizedDescription)
                return
            }
        }
    }
    
    func testC05_RevokeCard() {
        let ex = self.expectation(description: "Virgil Card should be created. Virgil card should be revoked");
        
        let numberOfRequests = 3
        let timeout = TimeInterval(numberOfRequests * kEstimatedRequestCompletionTime)
        
        let identityValue = NSUUID().uuidString
        let identity = self.api.identities.createUserIdentity(withValue: identityValue, type: "test")
        let key = self.api.keys.generateKey()
        
        let card = try! self.api.cards.createCard(with: identity, ownerKey: key)
        self.api.cards.publish(card) { (error) in
            sleep(3)
            
            self.api.cards.revoke(card) { error in
                XCTAssert(error == nil)
                ex.fulfill()
            }
        }
        
        self.waitForExpectations(timeout: timeout) { error in
            guard error == nil else {
                XCTFail("Expectation failed: " + error!.localizedDescription)
                return
            }
        }
    }
    
    func testA01_CreateGlobalEmailCard() {
        let ex = self.expectation(description: "Global Email Virgil Card should be created")
        
        let numberOfRequests = 5
        let timeout = TimeInterval(numberOfRequests * kEstimatedRequestCompletionTime + kEstimatedEmailReceiveTime)
        
        let identityValue = self.utils.generateEmail()
        let identity = self.api.identities.createEmailIdentity(withEmail: identityValue)
        
        identity.check(options: nil) { error in
            self.utils.getConfirmationCode(identityValue: identityValue, mailinator: self.mailinator) { confirmationCode in
                identity.confirm(withConfirmationCode: confirmationCode) { error in
                    let key = self.api.keys.generateKey()
                    
                    let card = try! self.api.cards.createCard(with: identity, ownerKey: key)
                    self.api.cards.publish(card) { (error) in
                        XCTAssert(error == nil)
                        XCTAssert(self.utils.checkHighLevelCardIsValid(card: card))
                        
                        ex.fulfill()
                    }
                }
            }
        }
        
        self.waitForExpectations(timeout: timeout) { error in
            guard error == nil else {
                XCTFail("Expectation failed: " + error!.localizedDescription)
                return
            }
        }
    }
    
    func testA02_RevokeGlobalEmailCard() {
        let ex = self.expectation(description: "Global Email Virgil Card should be created. Global Email Virgil Card should be revoked.")
        
        let numberOfRequests = 5
        let timeout = TimeInterval(numberOfRequests * kEstimatedRequestCompletionTime + 2 * kEstimatedEmailReceiveTime)
        
        let identityValue = self.utils.generateEmail()
        let identity = self.api.identities.createEmailIdentity(withEmail: identityValue)
        
        identity.check(options: nil) { error in
            self.utils.getConfirmationCode(identityValue: identityValue, mailinator: self.mailinator) { confirmationCode in
                identity.confirm(withConfirmationCode: confirmationCode) { error in
                    let key = self.api.keys.generateKey()
                    
                    let card = try! self.api.cards.createCard(with: identity, ownerKey: key)
                    self.api.cards.publish(card) { (error) in
                        let identity = self.api.identities.createEmailIdentity(withEmail: identityValue)
                        
                        identity.check(options: nil) { error in
                            self.utils.getConfirmationCode(emailNumber: 1, identityValue: identityValue, mailinator: self.mailinator) { confirmationCode in
                                identity.confirm(withConfirmationCode: confirmationCode) { error in
                                    self.api.cards.revokeEmail(card, identity: identity, ownerKey: key) { error in
                                        XCTAssert(error == nil)
                                        
                                        ex.fulfill()
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
        self.waitForExpectations(timeout: timeout) { error in
            guard error == nil else {
                XCTFail("Expectation failed: " + error!.localizedDescription)
                return
            }
        }
    }
}
