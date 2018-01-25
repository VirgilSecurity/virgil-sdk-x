//
//  DataExtensionsTests.swift
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 9/15/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

import Foundation
import VirgilSDK
import XCTest

class DataExtensionsTests: XCTestCase {
    
    func test001_base64Url() {
        let length = 2048
        let bytes = [UInt32](repeating: 0, count: length).map { _ in arc4random() }
        let data = Data(bytes: bytes, count: length)
        
        let base64url = data.base64UrlEncoded()

        let newData = Data(base64UrlEncoded: base64url)
        
        XCTAssert(newData != nil)
        
        XCTAssert(data == newData!)
    }
    
    func test001_hex() {
        let str = "This is a test."
        let strHex = "54686973206973206120746573742e"
        
        XCTAssert(str.data(using: .utf8)!.hexEncodedString() == strHex)
        
        XCTAssert(String(data: Data(hexEncodedString: strHex)!, encoding: .utf8) == str)
    }
}
