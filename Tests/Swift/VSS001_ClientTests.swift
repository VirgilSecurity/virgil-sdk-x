//
//  VirgilSDKTestsSwift.swift
//  VirgilSDKTestsSwift
//
//  Created by Oleksandr Deundiak on 10/8/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

import XCTest
import VirgilSDK

/// Each request should be done less than or equal this number of seconds.
let kEstimatedRequestCompletionTime = 12

class VSS001_ClientTests: XCTestCase {
    
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
        let config = VSSServiceConfig(token: self.consts.applicationToken)
        config.cardValidator = validator
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
    func testC01_CreateCard() {
        let ex = self.expectation(description: "Virgil Card should be created")
        
        let numberOfRequests = 1
        let timeout = TimeInterval(numberOfRequests * kEstimatedRequestCompletionTime)
        
        let request = self.utils.instantiateCreateCardRequest()
        
        self.client.createCardWith(request) { (registeredCard, error) in
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
        
        let request = self.utils.instantiateCreateCardRequest(with: ["custom_key1": "custom_field1", "custom_key2": "custom_field2"])
        
        self.client.createCardWith(request) { (registeredCard, error) in
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
        
        let request = self.utils.instantiateCreateCardRequest()
        
        self.client.createCardWith(request) { (registeredCard, error) in
            guard error == nil else {
                XCTFail("Failed: " + error!.localizedDescription)
                return
            }
            
            let criteria = VSSSearchCardsCriteria(scope: .application, identityType: registeredCard!.identityType, identities: [registeredCard!.identity])
            
            sleep(3)
            
            self.client.searchCards(using: criteria) { cards, error in
                guard error == nil else {
                    XCTFail("Failed: " + error!.localizedDescription)
                    return
                }
                
                guard let foundCards = cards else {
                    XCTFail("Found card == nil")
                    return
                }
                
                XCTAssert(foundCards.count == 1);
                XCTAssert(self.utils.check(card: foundCards[0], isEqualToCard: registeredCard!))
                
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
        
        let request = self.utils.instantiateCreateCardRequest()
        
        self.client.createCardWith(request) { (registeredCard, error) in
            guard error == nil else {
                XCTFail("Failed: " + error!.localizedDescription)
                return
            }
            
            sleep(3)
            self.client.getCard(withId: registeredCard!.identifier) { card, error in
                guard error == nil else {
                    XCTFail("Failed: " + error!.localizedDescription)
                    return
                }
                
                guard let foundCard = card else {
                    XCTFail("Found card == nil")
                    return
                }
                
                XCTAssert(foundCard.identifier == registeredCard!.identifier)
                XCTAssert(self.utils.check(card: foundCard, isEqualToCard: registeredCard!))
                
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
        
        let numberOfRequests = 2
        let timeout = TimeInterval(numberOfRequests * kEstimatedRequestCompletionTime)
        
        let request = self.utils.instantiateCreateCardRequest()
        
        self.client.createCardWith(request) { (registeredCard, error) in
            guard error == nil else {
                XCTFail("Failed: " + error!.localizedDescription)
                return
            }

            let revokeRequest = self.utils.instantiateRevokeCardRequestFor(card: registeredCard!)
            
            sleep(3)
            self.client.revokeCardWith(revokeRequest) { error in
                guard error == nil else {
                    XCTFail("Failed: " + error!.localizedDescription)
                    return
                }
                
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
    
    func testI01_VerifyEmail() {
        let ex = self.expectation(description: "Verification code should be sent to email");
        
        let numberOfRequests = 3
        let timeout = TimeInterval(numberOfRequests * kEstimatedRequestCompletionTime)
        
        let identity = self.utils.generateEmail()
        
        self.client.verifyIdentity(identity, identityType: "email", extraFields: nil) { actionId, error in
            XCTAssert(error == nil)
            XCTAssert(actionId != nil)
            XCTAssert(actionId!.lengthOfBytes(using: .utf8) != 0)
            
            sleep(10)
            
            let identityShort = identity.substring(to: identity.range(of: "@")!.lowerBound)
            
            self.mailinator.getInbox(identityShort) { metadataList, error in
                XCTAssert(error == nil)
                XCTAssert(metadataList != nil)
                XCTAssert(metadataList!.count == 1)
                
                self.mailinator.getEmail(metadataList![0].mid) { email, error in
                    XCTAssert(error == nil)
                    XCTAssert(email != nil)
                    
                    let bodyPart = email!.parts[0];
                    
                    let matchResult = self.regexp.firstMatch(in: bodyPart.body, options: .reportCompletion, range: NSMakeRange(0, bodyPart.body.lengthOfBytes(using: .utf8)))
                    
                    let match = (bodyPart.body as NSString).substring(with: matchResult!.range)
                    
                    let code = String(match.characters.suffix(6))
                    
                    XCTAssert(code.lengthOfBytes(using: .utf8) == 6)
                    
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
    
    func testI02_ConfirmEmail() {
        let ex = self.expectation(description: "Verification code should be sent to email. Validation token should be obtained");
        
        let numberOfRequests = 4
        let timeout = TimeInterval(numberOfRequests * kEstimatedRequestCompletionTime)
        
        let identity = self.utils.generateEmail()
        
        self.client.verifyIdentity(identity, identityType: "email", extraFields: nil) { actionId, error in
            sleep(10)
            
            let identityShort = identity.substring(to: identity.range(of: "@")!.lowerBound)
            
            self.mailinator.getInbox(identityShort) { metadataList, error in
                self.mailinator.getEmail(metadataList![0].mid) { email, error in
                    let bodyPart = email!.parts[0];
                    
                    let matchResult = self.regexp.firstMatch(in: bodyPart.body, options: .reportCompletion, range: NSMakeRange(0, bodyPart.body.lengthOfBytes(using: .utf8)))
                    
                    let match = (bodyPart.body as NSString).substring(with: matchResult!.range)
                    
                    let code = String(match.characters.suffix(6))
                    
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
        let timeout = TimeInterval(numberOfRequests * kEstimatedRequestCompletionTime)
        
        let identity = self.utils.generateEmail()
        
        self.client.verifyIdentity(identity, identityType: "email", extraFields: nil) { actionId, error in
            sleep(10)
            
            let identityShort = identity.substring(to: identity.range(of: "@")!.lowerBound)
            
            self.mailinator.getInbox(identityShort) { metadataList, error in
                self.mailinator.getEmail(metadataList![0].mid) { email, error in
                    let bodyPart = email!.parts[0];
                    
                    let matchResult = self.regexp.firstMatch(in: bodyPart.body, options: .reportCompletion, range: NSMakeRange(0, bodyPart.body.lengthOfBytes(using: .utf8)))
                    
                    let match = (bodyPart.body as NSString).substring(with: matchResult!.range)
                    
                    let code = String(match.characters.suffix(6))
                    
                    self.client.confirmIdentity(withActionId: actionId!, confirmationCode: code, timeToLive: 3600, countToLive: 12) { response, error in
                        self.client.validateIdentity(identity, identityType: "email", validationToken: response!.validationToken) { error in
                            XCTAssert(error == nil)
                            
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
    
    func testA01_CreateGlobalEmailCard() {
        let ex = self.expectation(description: "Global Email Virgil Card should be created")
        
        let numberOfRequests = 5
        let timeout = TimeInterval(numberOfRequests * kEstimatedRequestCompletionTime)
        
        let identity = self.utils.generateEmail()
        
        self.client.verifyIdentity(identity, identityType: "email", extraFields: nil) { actionId, error in
            sleep(10)
            
            let identityShort = identity.substring(to: identity.range(of: "@")!.lowerBound)
            
            self.mailinator.getInbox(identityShort) { metadataList, error in
                self.mailinator.getEmail(metadataList![0].mid) { email, error in
                    let bodyPart = email!.parts[0];
                    
                    let matchResult = self.regexp.firstMatch(in: bodyPart.body, options: .reportCompletion, range: NSMakeRange(0, bodyPart.body.lengthOfBytes(using: .utf8)))
                    
                    let match = (bodyPart.body as NSString).substring(with: matchResult!.range)
                    
                    let code = String(match.characters.suffix(6))
                    
                    self.client.confirmIdentity(withActionId: actionId!, confirmationCode: code, timeToLive: 3600, countToLive: 12) { response, error in
                        
                        let request = self.utils.instantiateEmailCreateCardRequest(withIdentity: identity, validationToken: response!.validationToken, keyPair: nil)
                        
                        self.client.createGlobalCardWith(request) { (registeredCard, error) in
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
        let timeout = TimeInterval(numberOfRequests * kEstimatedRequestCompletionTime)
        
        let identity = self.utils.generateEmail()
        
        self.client.verifyIdentity(identity, identityType: "email", extraFields: nil) { actionId, error in
            sleep(10)
            
            let identityShort = identity.substring(to: identity.range(of: "@")!.lowerBound)
            
            self.mailinator.getInbox(identityShort) { metadataList, error in
                self.mailinator.getEmail(metadataList![0].mid) { email, error in
                    let bodyPart = email!.parts[0];
                    
                    let matchResult = self.regexp.firstMatch(in: bodyPart.body, options: .reportCompletion, range: NSMakeRange(0, bodyPart.body.lengthOfBytes(using: .utf8)))
                    
                    let match = (bodyPart.body as NSString).substring(with: matchResult!.range)
                    
                    let code = String(match.characters.suffix(6))
                    
                    self.client.confirmIdentity(withActionId: actionId!, confirmationCode: code, timeToLive: 3600, countToLive: 12) { response, error in
                        let keyPair = self.crypto.generateKeyPair()
                        let request = self.utils.instantiateEmailCreateCardRequest(withIdentity: identity, validationToken: response!.validationToken, keyPair: keyPair)
                        
                        self.client.createGlobalCardWith(request) { (registeredCard, error) in
                            let revokeRequest = self.utils.instantiateRevokeGlobalCardRequestFor(card: registeredCard!, validationToken:response!.validationToken, privateKey: keyPair.privateKey)
                            
                            self.client.revokeGlobalCardWith(revokeRequest, completion: { error in
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
        }
        
        self.waitForExpectations(timeout: timeout) { error in
            guard error == nil else {
                XCTFail("Expectation failed: " + error!.localizedDescription)
                return
            }
        }
    }
}
