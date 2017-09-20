//
//  HexTests.swift
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 9/15/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

import Foundation
import VirgilSDK
import XCTest

// FIXME
class HexTests: XCTestCase {
    func test001() {
        let str = "This is a test."
        let strHex = "54686973206973206120746573742e"
        
        XCTAssert(str.data(using: .utf8)!.hexEncodedString() == strHex)
        
        XCTAssert(String(data: Data(hexEncodedString: strHex)!, encoding: .utf8) == str)
    }
}
