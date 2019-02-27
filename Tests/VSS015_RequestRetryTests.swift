//
// Copyright (C) 2015-2019 Virgil Security Inc.
//
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are
// met:
//
//     (1) Redistributions of source code must retain the above copyright
//     notice, this list of conditions and the following disclaimer.
//
//     (2) Redistributions in binary form must reproduce the above copyright
//     notice, this list of conditions and the following disclaimer in
//     the documentation and/or other materials provided with the
//     distribution.
//
//     (3) Neither the name of the copyright holder nor the names of its
//     contributors may be used to endorse or promote products derived from
//     this software without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE AUTHOR ''AS IS'' AND ANY EXPRESS OR
// IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
// WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT,
// INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
// HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
// STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING
// IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.
//
// Lead Maintainer: Virgil Security Inc. <support@virgilsecurity.com>
//

import Foundation
import XCTest
import VirgilSDK

class VSS015_RequestRetryTests: XCTestCase {
    func test1() {
        for _ in 0..<100 {
            let config = RequestRetry.Config(maxRetryCount: 3, cap: 10, minDelay: 5, base: 3, exp: 2)
            let retry = RequestRetry(config: config)
            
            let delay1 = try! retry.nextRetryDelay()
            let delay2 = try! retry.nextRetryDelay()
            let delay3 = try! retry.nextRetryDelay()
            
            XCTAssert(delay1 == 5)
            XCTAssert(5 <= delay2 && delay2 <= 6)
            XCTAssert(5 <= delay3 && delay3 <= 10)
            
            do {
                _ = try retry.nextRetryDelay()
                XCTFail()
            }
            catch { }
        }
    }
    
    func test2() {
        let retry = RequestRetry()
        
        let statusCode = 500
        
        let request = try! ServiceRequest(url: URL(string: "https://example.com/")!, method: .post)
        
        let urlResponse = HTTPURLResponse(url: URL(string: "https://example.com/")!, statusCode: statusCode, httpVersion: nil, headerFields: nil)!
        
        let response = Response(statusCode: statusCode, response: urlResponse, body: nil)
        
        guard case .retryService(_) = retry.retryChoice(for: request, with: response) else {
            XCTFail()
            return
        }
    }
    
    func test3() {
        let retry = RequestRetry()
        
        let request = try! ServiceRequest(url: URL(string: "https://example.com/")!, method: .post)
        
        let statusCode = 200
        
        let urlResponse = HTTPURLResponse(url: URL(string: "https://example.com/")!, statusCode: statusCode, httpVersion: nil, headerFields: nil)!
        
        let response = Response(statusCode: statusCode, response: urlResponse, body: nil)
        
        guard case .noRetry = retry.retryChoice(for: request, with: response) else {
            XCTFail()
            return
        }
    }
}
