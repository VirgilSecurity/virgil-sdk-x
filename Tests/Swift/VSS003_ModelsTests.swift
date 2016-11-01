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
    
    // MARK: Setup
    
    override func setUp() {
        super.setUp()
        
        self.utils = VSSTestUtils(crypto: VSSCrypto(), consts: VSSTestsConst())
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
}
