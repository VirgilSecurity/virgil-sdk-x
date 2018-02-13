//
//  VSS008_DataExtensionsTests.swift
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 9/15/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

import Foundation
import VirgilSDK
import XCTest

class VSS008_DataExtensionsTests: XCTestCase {
    func test001_base64Url() {
        let base64encoded = "MFEwDQYJYIZIAWUDBAIDBQAEQJuTxlQ7r+RG2P8D12OFOdgPsIDmZMd4UBMIG1c1Amqm/oc1wRUzk7ccz1RbTWEt2XP+1GbkF0Z6s6FYf1QEUQI="
        let base64UrlEncoded = "MFEwDQYJYIZIAWUDBAIDBQAEQJuTxlQ7r-RG2P8D12OFOdgPsIDmZMd4UBMIG1c1Amqm_oc1wRUzk7ccz1RbTWEt2XP-1GbkF0Z6s6FYf1QEUQI"

        let data = Data(base64Encoded: base64encoded)!
        
        let base64url = data.base64UrlEncodedString()

        XCTAssert(base64url == base64UrlEncoded)

        let newData = Data(base64UrlEncoded: base64url)
        
        XCTAssert(newData != nil)
        
        XCTAssert(data == newData!)
    }
    
    func test002_hex() {
        let str = "This is a test."
        let strHex = "54686973206973206120746573742e"
        
        XCTAssert(str.data(using: .utf8)!.hexEncodedString() == strHex)
        
        XCTAssert(String(data: Data(hexEncodedString: strHex)!, encoding: .utf8) == str)
    }
}
