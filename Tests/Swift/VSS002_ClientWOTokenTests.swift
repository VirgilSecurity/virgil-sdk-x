//
//  VSS002_ClientWOTokenTests.swift
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 2/8/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

import XCTest
import VirgilSDK

class VSS002_ClientWOTokenTests: XCTestCase {
    
    private var client: VSSClient!
    private var crypto: VSSCrypto!
    private var utils: VSSTestUtils!
    private var consts: VSSTestsConst!
    private var regexp: NSRegularExpression!
    private var mailinator: Mailinator!
    
    // MARK: Setup
    
    override func setUp() {
        super.setUp()
        
        self.consts = VSSTestsConst()
        self.crypto = VSSCrypto()
        
        let validator = VSSCardValidator(crypto: self.crypto)
        let privateKey = self.crypto.importPrivateKey(from: Data(base64Encoded: self.consts.applicationPrivateKeyBase64)!, withPassword: self.consts.applicationPrivateKeyPassword)!
        let publicKey = self.crypto.extractPublicKey(from: privateKey)
        let publicKeyData = self.crypto.export(publicKey)
        XCTAssert(validator.addVerifier(withId: self.consts.applicationId, publicKeyData: publicKeyData))
        let config = VSSServiceConfig.default()
        validator.useVirgilServiceVerifiers = false
        config.cardValidator = validator
        
        config.cardsServiceURL = self.consts.cardsServiceURL
        config.cardsServiceROURL = self.consts.cardsServiceROURL
        config.identityServiceURL = self.consts.identityServiceURL
        config.registrationAuthorityURL = self.consts.registrationAuthorityURL
        
        self.client = VSSClient(serviceConfig: config)
        
        self.utils = VSSTestUtils(crypto: self.crypto, consts: self.consts)
        
        self.regexp = try! NSRegularExpression(pattern: "Your confirmation code is.+([A-Z0-9]{6})", options: .caseInsensitive)
        
        self.mailinator = Mailinator(applicationToken: self.consts.mailinatorToken, serviceUrl: URL(string: "https://api.mailinator.com/api/")!)
    }
    
    override func tearDown() {
        self.client = nil
        self.crypto = nil
        self.utils = nil
        self.consts = nil
        
        super.tearDown()
    }
    
    // MARK: Tests
    func testI01_VerifyEmail() {
        let ex = self.expectation(description: "Verification code should be sent to email");
        
        let numberOfRequests = 3
        let timeout = TimeInterval(numberOfRequests * kEstimatedRequestCompletionTime + kEstimatedEmailReceiveTime)
        
        let identity = self.utils.generateEmail()
        
        self.client.verifyIdentity(identity, identityType: "email", extraFields: nil) { actionId, error in
            XCTAssert(error == nil)
            XCTAssert(actionId != nil)
            XCTAssert(actionId!.lengthOfBytes(using: .utf8) != 0)
            
            self.utils.getConfirmationCode(identityValue: identity, mailinator: self.mailinator) { code in
                XCTAssert(code.lengthOfBytes(using: .utf8) == 6)
                
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
    
    func testI02_ConfirmEmail() {
        let ex = self.expectation(description: "Verification code should be sent to email. Validation token should be obtained");
        
        let numberOfRequests = 4
        let timeout = TimeInterval(numberOfRequests * kEstimatedRequestCompletionTime + kEstimatedEmailReceiveTime)
        
        let identity = self.utils.generateEmail()
        
        self.client.verifyIdentity(identity, identityType: "email", extraFields: nil) { actionId, error in
            self.utils.getConfirmationCode(identityValue: identity, mailinator: self.mailinator) { code in
                self.client.confirmIdentity(withActionId: actionId!, confirmationCode: code, timeToLive: 3600, countToLive: 12) { response, error in
                    XCTAssert(error == nil)
                    XCTAssert(response != nil)
                    XCTAssert(response!.identityType == "email")
                    XCTAssert(response!.identityValue == identity)
                    XCTAssert(response!.validationToken.lengthOfBytes(using: .utf8) != 0)
                    
                    ex.fulfill()
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
    
    func testI03_ValidateEmail() {
        let ex = self.expectation(description: "Verification code should be sent to email. Validation token should be obtained. Confirmation should pass");
        
        let numberOfRequests = 5
        let timeout = TimeInterval(numberOfRequests * kEstimatedRequestCompletionTime + kEstimatedEmailReceiveTime)
        
        let identity = self.utils.generateEmail()
        
        self.client.verifyIdentity(identity, identityType: "email", extraFields: nil) { actionId, error in
            self.utils.getConfirmationCode(identityValue: identity, mailinator: self.mailinator) { code in
                self.client.confirmIdentity(withActionId: actionId!, confirmationCode: code, timeToLive: 3600, countToLive: 12) { response, error in
                    self.client.validateIdentity(identity, identityType: "email", validationToken: response!.validationToken) { error in
                        XCTAssert(error == nil)
                        
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
    
    func testA01_CreateGlobalEmailCard() {
        let ex = self.expectation(description: "Global Email Virgil Card should be created")
        
        let numberOfRequests = 5
        let timeout = TimeInterval(numberOfRequests * kEstimatedRequestCompletionTime + kEstimatedEmailReceiveTime)
        
        let identity = self.utils.generateEmail()
        
        self.client.verifyIdentity(identity, identityType: "email", extraFields: nil) { actionId, error in
            self.utils.getConfirmationCode(identityValue: identity, mailinator: self.mailinator) { code in
                self.client.confirmIdentity(withActionId: actionId!, confirmationCode: code, timeToLive: 3600, countToLive: 12) { response, error in
                    
                    let request = self.utils.instantiateEmailCreateCardRequest(withIdentity: identity, validationToken: response!.validationToken, keyPair: nil)
                    
                    self.client.createCard(with: request) { (registeredCard, error) in
                        guard error == nil else {
                            XCTFail("Failed: " + error!.localizedDescription)
                            return
                        }
                        
                        guard let card = registeredCard else {
                            XCTFail("Card is nil")
                            return
                        }
                        
                        XCTAssert(self.utils.check(card: card, isEqualToCreateCardRequest: request))
                        
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
        
        let numberOfRequests = 6
        let timeout = TimeInterval(numberOfRequests * kEstimatedRequestCompletionTime + kEstimatedEmailReceiveTime)
        
        let identity = self.utils.generateEmail()
        
        self.client.verifyIdentity(identity, identityType: "email", extraFields: nil) { actionId, error in
            self.utils.getConfirmationCode(identityValue: identity, mailinator: self.mailinator) { code in
                self.client.confirmIdentity(withActionId: actionId!, confirmationCode: code, timeToLive: 3600, countToLive: 12) { response, error in
                    let keyPair = self.crypto.generateKeyPair()
                    let request = self.utils.instantiateEmailCreateCardRequest(withIdentity: identity, validationToken: response!.validationToken, keyPair: keyPair)
                    
                    self.client.createCard(with: request) { (registeredCard, error) in
                        let revokeRequest = self.utils.instantiateRevokeGlobalCardRequestFor(card: registeredCard!, validationToken:response!.validationToken, privateKey: keyPair.privateKey)
                        
                        self.client.revokeCardWith(revokeRequest, completion: { error in
                            guard error == nil else {
                                XCTFail("Failed: " + error!.localizedDescription)
                                return
                            }
                            
                            ex.fulfill()
                        })
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
    
    func testAU01_GetChallengeMessage() {
        let ex = self.expectation(description: "Global Email Virgil Card should be created. Challenge message for this card should be received.")
        
        let numberOfRequests = 6
        let timeout = TimeInterval(numberOfRequests * kEstimatedRequestCompletionTime + kEstimatedEmailReceiveTime)
        
        let identity = self.utils.generateEmail()
        
        self.client.verifyIdentity(identity, identityType: "email", extraFields: nil) { actionId, error in
            self.utils.getConfirmationCode(identityValue: identity, mailinator: self.mailinator) { code in
                self.client.confirmIdentity(withActionId: actionId!, confirmationCode: code, timeToLive: 3600, countToLive: 12) { response, error in
                    let keyPair = self.crypto.generateKeyPair()
                    let request = self.utils.instantiateEmailCreateCardRequest(withIdentity: identity, validationToken: response!.validationToken, keyPair: keyPair)
                    
                    self.client.createCard(with: request) { (registeredCard, error) in
                        self.client.getChallengeMessageForVirgilCard(withId: registeredCard!.identifier) { response, error in
                            XCTAssert(error == nil && response != nil)
                            XCTAssert(!response!.authGrantId.isEmpty && !response!.encryptedMessage.isEmpty)
                            
                            ex.fulfill()
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
    
    func testAU02_AckChallengeMessage() {
        let ex = self.expectation(description: "Global Email Virgil Card should be created. Challenge message for this card should be received. Acknowledge should return access code.")
        
        let numberOfRequests = 7
        let timeout = TimeInterval(numberOfRequests * kEstimatedRequestCompletionTime + kEstimatedEmailReceiveTime)
        
        let identity = self.utils.generateEmail()
        
        self.client.verifyIdentity(identity, identityType: "email", extraFields: nil) { actionId, error in
            self.utils.getConfirmationCode(identityValue: identity, mailinator: self.mailinator) { code in
                self.client.confirmIdentity(withActionId: actionId!, confirmationCode: code, timeToLive: 3600, countToLive: 12) { response, error in
                    let keyPair = self.crypto.generateKeyPair()
                    let request = self.utils.instantiateEmailCreateCardRequest(withIdentity: identity, validationToken: response!.validationToken, keyPair: keyPair)
                    
                    self.client.createCard(with: request) { (registeredCard, error) in
                        self.client.getChallengeMessageForVirgilCard(withId: registeredCard!.identifier) { response, error in
                            XCTAssert(error == nil)
                            XCTAssert(response != nil)
                            XCTAssert(!response!.authGrantId.isEmpty && !response!.encryptedMessage.isEmpty)
                            
                            let message = try! self.crypto.decrypt(response!.encryptedMessage, with: keyPair.privateKey)
                            
                            
                            let virgilAuthPublicKeyData = Data(base64Encoded: kVSSAuthServicePublicKeyInBase64)!
                            let virgilAuthPublicKey = self.crypto.importPublicKey(from: virgilAuthPublicKeyData)!
                            let encryptedMessage = try! self.crypto.encrypt(message, for: [virgilAuthPublicKey])
                            
                            self.client.ackChallengeMessage(withAuthGrantId: response!.authGrantId, encryptedMessage: encryptedMessage) { code, error in
                                XCTAssert(error == nil && code != nil)
                                XCTAssert(!code!.isEmpty)
                                
                                ex.fulfill()
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
    
    func testAU03_ObtainAccessToken() {
        let ex = self.expectation(description: "Global Email Virgil Card should be created. Challenge message for this card should be received. Acknowledge should return access code. Token should be received.")
        
        let numberOfRequests = 8
        let timeout = TimeInterval(numberOfRequests * kEstimatedRequestCompletionTime + kEstimatedEmailReceiveTime)
        
        let identity = self.utils.generateEmail()
        
        self.client.verifyIdentity(identity, identityType: "email", extraFields: nil) { actionId, error in
            self.utils.getConfirmationCode(identityValue: identity, mailinator: self.mailinator) { code in
                self.client.confirmIdentity(withActionId: actionId!, confirmationCode: code, timeToLive: 3600, countToLive: 12) { response, error in
                    let keyPair = self.crypto.generateKeyPair()
                    let request = self.utils.instantiateEmailCreateCardRequest(withIdentity: identity, validationToken: response!.validationToken, keyPair: keyPair)
                    
                    self.client.createCard(with: request) { (registeredCard, error) in
                        self.client.getChallengeMessageForVirgilCard(withId: registeredCard!.identifier) { response, error in
                            XCTAssert(error == nil && response != nil)
                            XCTAssert(!response!.authGrantId.isEmpty && !response!.encryptedMessage.isEmpty)
                            
                            let message = try! self.crypto.decrypt(response!.encryptedMessage, with: keyPair.privateKey)
                            
                            
                            let virgilAuthPublicKeyData = Data(base64Encoded: kVSSAuthServicePublicKeyInBase64)!
                            let virgilAuthPublicKey = self.crypto.importPublicKey(from: virgilAuthPublicKeyData)!
                            let encryptedMessage = try! self.crypto.encrypt(message, for: [virgilAuthPublicKey])
                            
                            self.client.ackChallengeMessage(withAuthGrantId: response!.authGrantId, encryptedMessage: encryptedMessage) { code, error in
                                self.client.obtainAccessToken(withAccessCode: code!) { response, error in
                                    XCTAssert(error == nil)
                                    XCTAssert(response != nil)
                                    XCTAssert(!response!.refreshToken.isEmpty)
                                    XCTAssert(!response!.accessToken.isEmpty)
                                    XCTAssert(!response!.tokenType.isEmpty)
                                    XCTAssert(response!.expiresIn != 0)
                                    
                                    ex.fulfill()
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
    
    func testAU04_RefreshAccessToken() {
        let ex = self.expectation(description: "Global Email Virgil Card should be created. Challenge message for this card should be received. Acknowledge should return access code. Token should be received. Token should be refreshed.")
        
        let numberOfRequests = 9
        let timeout = TimeInterval(numberOfRequests * kEstimatedRequestCompletionTime + kEstimatedEmailReceiveTime)
        
        let identity = self.utils.generateEmail()
        
        self.client.verifyIdentity(identity, identityType: "email", extraFields: nil) { actionId, error in
            self.utils.getConfirmationCode(identityValue: identity, mailinator: self.mailinator) { code in
                self.client.confirmIdentity(withActionId: actionId!, confirmationCode: code, timeToLive: 3600, countToLive: 12) { response, error in
                    let keyPair = self.crypto.generateKeyPair()
                    let request = self.utils.instantiateEmailCreateCardRequest(withIdentity: identity, validationToken: response!.validationToken, keyPair: keyPair)
                    
                    self.client.createCard(with: request) { (registeredCard, error) in
                        self.client.getChallengeMessageForVirgilCard(withId: registeredCard!.identifier) { response, error in
                            XCTAssert(error == nil && response != nil)
                            XCTAssert(!response!.authGrantId.isEmpty && !response!.encryptedMessage.isEmpty)
                            
                            let message = try! self.crypto.decrypt(response!.encryptedMessage, with: keyPair.privateKey)
                            
                            
                            let virgilAuthPublicKeyData = Data(base64Encoded: kVSSAuthServicePublicKeyInBase64)!
                            let virgilAuthPublicKey = self.crypto.importPublicKey(from: virgilAuthPublicKeyData)!
                            let encryptedMessage = try! self.crypto.encrypt(message, for: [virgilAuthPublicKey])
                            
                            self.client.ackChallengeMessage(withAuthGrantId: response!.authGrantId, encryptedMessage: encryptedMessage) { code, error in
                                self.client.obtainAccessToken(withAccessCode: code!) { response, error in
                                    self.client.refreshAccessToken(withRefreshToken: response!.refreshToken) { response, error in
                                        XCTAssert(error == nil)
                                        XCTAssert(response != nil)
                                        XCTAssert(!response!.accessToken.isEmpty)
                                        XCTAssert(response!.expiresIn != 0)
                                        
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
    
    func testAU05_VerifyAccessToken() {
        let ex = self.expectation(description: "Global Email Virgil Card should be created. Challenge message for this card should be received. Acknowledge should return access code. Token should be received. Token should be verified.")
        
        let numberOfRequests = 9
        let timeout = TimeInterval(numberOfRequests * kEstimatedRequestCompletionTime + kEstimatedEmailReceiveTime)
        
        let identity = self.utils.generateEmail()
        
        self.client.verifyIdentity(identity, identityType: "email", extraFields: nil) { actionId, error in
            self.utils.getConfirmationCode(identityValue: identity, mailinator: self.mailinator) { code in
                self.client.confirmIdentity(withActionId: actionId!, confirmationCode: code, timeToLive: 3600, countToLive: 12) { response, error in
                    let keyPair = self.crypto.generateKeyPair()
                    let request = self.utils.instantiateEmailCreateCardRequest(withIdentity: identity, validationToken: response!.validationToken, keyPair: keyPair)
                    
                    self.client.createCard(with: request) { (registeredCard, error) in
                        self.client.getChallengeMessageForVirgilCard(withId: registeredCard!.identifier) { response, error in
                            XCTAssert(error == nil && response != nil)
                            XCTAssert(!response!.authGrantId.isEmpty && !response!.encryptedMessage.isEmpty)
                            
                            let message = try! self.crypto.decrypt(response!.encryptedMessage, with: keyPair.privateKey)
                            
                            
                            let virgilAuthPublicKeyData = Data(base64Encoded: kVSSAuthServicePublicKeyInBase64)!
                            let virgilAuthPublicKey = self.crypto.importPublicKey(from: virgilAuthPublicKeyData)!
                            let encryptedMessage = try! self.crypto.encrypt(message, for: [virgilAuthPublicKey])
                            
                            self.client.ackChallengeMessage(withAuthGrantId: response!.authGrantId, encryptedMessage: encryptedMessage) { code, error in
                                self.client.obtainAccessToken(withAccessCode: code!) { response, error in
                                    self.client.verifyAccessToken(response!.accessToken) { cardId, error in
                                        XCTAssert(error == nil)
                                        XCTAssert(cardId! == registeredCard!.identifier)
                                        
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
