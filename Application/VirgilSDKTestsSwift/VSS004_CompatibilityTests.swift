//
//  VSS004_CompatibilityTests.swift
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 10/17/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

import Foundation
import XCTest

class VSS004_CompatibilityTests: XCTestCase {
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
}
