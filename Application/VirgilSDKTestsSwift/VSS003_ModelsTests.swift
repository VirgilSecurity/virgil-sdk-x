//
//  VSS003_ModelsTests.swift
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 10/17/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

import Foundation
import XCTest

class VSS003_ModelsTests: XCTestCase {
    private var utils: VSSTestUtils!
    
    // MARK: Setup
    
    override func setUp() {
        super.setUp()
        
        self.utils = VSSTestUtils(crypto: VSSCrypto())
    }
    
    override func tearDown() {
        self.utils = nil
        
        super.tearDown()
    }
    
    func test001_CardImportExport() {
        let card = self.utils.instantiateCard()!
        
        let exportedData = card.exportData()
        
        let importedCard = VSSCard(data: exportedData)!
        
        XCTAssert(self.utils.check(card: card, isEqualToCard: importedCard))
    }

    func test002_RevokeCardImportExport() {
        let revokeCard = VSSRevokeCard(id: "testId", reason: .unspecified)
        
        let exportedData = revokeCard.exportData()
        
        let importedRevokeCard = VSSRevokeCard(data: exportedData)!
        
        XCTAssert(self.utils.check(card: revokeCard, isEqualToCard: importedRevokeCard))
    }
}
