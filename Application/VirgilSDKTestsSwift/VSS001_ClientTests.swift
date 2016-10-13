//
//  VirgilSDKTestsSwift.swift
//  VirgilSDKTestsSwift
//
//  Created by Oleksandr Deundiak on 10/8/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

import XCTest

/// Each request should be done less than or equal this number of seconds.
let kEstimatedRequestCompletionTime = 5

class VSS001_ClientTests: XCTestCase {
    
    private var client: VSSClient!
    private var crypto: VSSCrypto!
    private var utils: VSSTestUtils!
    
    // MARK: Setup
    
    override func setUp() {
        super.setUp()
        
        self.client = VSSClient(applicationToken: kApplicationToken)
        self.crypto = VSSCrypto()
        self.utils = VSSTestUtils(crypto: self.crypto)
        self.continueAfterFailure = false
    }
    
    override func tearDown() {
        self.client = nil
        self.crypto = nil
        self.utils = nil
        
        super.tearDown()
    }
    
    // MARK: Tests
    func test001_CreateCard() {
        let ex = self.expectation(description: "Virgil Card should be created")
        
        let numberOfRequests = 1
        let timeout = TimeInterval(numberOfRequests * kEstimatedRequestCompletionTime)
        
        let instantiatedCard = self.utils.instantiateCard()!
        
        self.client.createCard(instantiatedCard, completion: { (card, error) in
            guard error == nil else {
                XCTFail("Failed: " + error!.localizedDescription)
                return
            }
            
            guard let createdCard = card else {
                XCTFail("Card is nil")
                return
            }
            
            XCTAssert(!createdCard.identifier!.isEmpty)
            XCTAssert(self.utils.check(card: instantiatedCard, isEqualToCard: createdCard))
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
    
    func test002_SearchCards() {
        let ex = self.expectation(description: "Virgil Card should be created. Search should return 1 card that is equal to created card");
        
        let numberOfRequests = 2
        let timeout = TimeInterval(numberOfRequests * kEstimatedRequestCompletionTime)
        
        let instantiatedCard = self.utils.instantiateCard()!
        
        self.client.createCard(instantiatedCard, completion: { (card, error) in
            guard error == nil else {
                XCTFail("Failed: " + error!.localizedDescription)
                return
            }
            
            let searchCards = VSSSearchCards(scope: .application, identityType: card!.data.identityType, identities: [card!.data.identity])
            self.client.searchCards(searchCards, completion: { cards, error in
                guard error == nil else {
                    XCTFail("Failed: " + error!.localizedDescription)
                    return
                }
                
                guard let foundCards = cards else {
                    XCTFail("Found card == nil")
                    return
                }
                
                XCTAssert(foundCards.count == 1);
                XCTAssert(self.utils.check(card: foundCards[0], isEqualToCard: card!))
                
                ex.fulfill()
            })
        })
        
        self.waitForExpectations(timeout: timeout, handler: { error in
            guard error == nil else {
                XCTFail("Expectation failed: " + error!.localizedDescription)
                return
            }
        })
    }
    
    func test003_GetCard() {
        let ex = self.expectation(description: "Virgil Card should be created. Get card request should return 1 card that is equal to created card");
        
        let numberOfRequests = 2
        let timeout = TimeInterval(numberOfRequests * kEstimatedRequestCompletionTime)
        
        let instantiatedCard = self.utils.instantiateCard()!
        
        self.client.createCard(instantiatedCard, completion: { (newCard, error) in
            guard error == nil else {
                XCTFail("Failed: " + error!.localizedDescription)
                return
            }
            
            self.client.getCardWithId(newCard!.identifier!, completion: { card, error in
                guard error == nil else {
                    XCTFail("Failed: " + error!.localizedDescription)
                    return
                }
                
                guard let foundCard = card else {
                    XCTFail("Found card == nil")
                    return
                }
                
                XCTAssert(foundCard.identifier == newCard!.identifier!)
                XCTAssert(self.utils.check(card: foundCard, isEqualToCard: newCard!))
                
                ex.fulfill()
            })
        })
        
        self.waitForExpectations(timeout: timeout, handler: { error in
            guard error == nil else {
                XCTFail("Expectation failed: " + error!.localizedDescription)
                return
            }
        })
    }

    // todo: Revoke card
}
