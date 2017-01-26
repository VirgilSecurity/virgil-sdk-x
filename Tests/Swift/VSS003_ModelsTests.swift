//
//  VSS003_ModelsTests.swift
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 10/17/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

import Foundation
import VirgilSDK
import XCTest

class VSS003_ModelsTests: XCTestCase {
    private var utils: VSSTestUtils!
    private var consts: VSSTestsConst!
    private var crypto: VSSCrypto!
    
    // MARK: Setup
    
    override func setUp() {
        super.setUp()
        
        self.consts = VSSTestsConst()
        self.crypto = VSSCrypto()
        self.utils = VSSTestUtils(crypto: self.crypto, consts: self.consts)
    }
    
    override func tearDown() {
        self.utils = nil
        
        super.tearDown()
    }
    
    func test001_CardImportExport() {
        let request = self.utils.instantiateCreateCardRequest()
        
        let exportedData = request.exportData()
        
        let importedRequest = VSSCreateCardRequest(data: exportedData)!
        
        XCTAssert(self.utils.check(createCardRequest: request, isEqualToCreateCardRequest: importedRequest))
    }

    func test002_RevokeCardImportExport() {
        let revokeRequest = VSSRevokeCardRequest(cardId: "testId", reason: .unspecified)
        
        let exportedData = revokeRequest.exportData()
        
        let importedRevokeRequest = VSSRevokeCardRequest(data: exportedData)!
        
        XCTAssert(self.utils.check(revokeCardRequest: revokeRequest, isEqualToRevokeCardRequest: importedRevokeRequest))
    }
    
    func test003_CardImportExport() {
        let card = utils.instantiateCard()
        
        let cardStr = card.exportData()
        
        let importedCard = VSSCard(data: cardStr)!
        
        XCTAssert(self.utils.check(card: card, isEqualToCard: importedCard))
        
        let validator = VSSCardValidator(crypto: self.crypto)
        let privateKey = self.crypto.importPrivateKey(from: Data(base64Encoded: self.consts.applicationPrivateKeyBase64)!, withPassword: self.consts.applicationPrivateKeyPassword)!
        let publicKey = self.crypto.extractPublicKey(from: privateKey)
        let publicKeyData = self.crypto.export(publicKey)
        XCTAssert(validator.addVerifier(withId: self.consts.applicationId, publicKeyData: publicKeyData))
        
        XCTAssert(validator.validate(importedCard.cardResponse));
    }
}
