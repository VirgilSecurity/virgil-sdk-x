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
@testable import VirgilSDK

class VSS015_ExpBackoffRetryTests: XCTestCase {
    let url = URL(string: "https://example.com/")!
    
    func test01__STC_43__nextRetryDelay__fixedConfig__shouldBeInCorrectRange() {
        for _ in 0..<100 {
            let config = ExpBackoffRetry.Config(maxRetryCount: 3, cap: 10, minDelay: 5, base: 3, exp: 2)
            let retry = ExpBackoffRetry(config: config)
            
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
    
    func test02__STC_44__retryChoice__status500__shouldTriggerServiceRetry() {
        let retry = ExpBackoffRetry()
        
        let request = try! ServiceRequest(url: self.url, method: .get)
        
        let statusCode = 500
        
        let urlResponse = HTTPURLResponse(url: self.url, statusCode: statusCode, httpVersion: nil, headerFields: nil)!
        
        let response = Response(statusCode: statusCode, response: urlResponse, body: nil)
        
        guard case .retryService(_) = retry.retryChoice(for: request, with: response) else {
            XCTFail()
            return
        }
    }
    
    func test03__STC_45__retryChoice__status401Expired__shouldTriggerAuthRetry() {
        let retry = ExpBackoffRetry()
        
        let request = try! ServiceRequest(url: self.url, method: .get)
        
        let statusCode = 401
        
        let urlResponse = HTTPURLResponse(url: self.url, statusCode: statusCode, httpVersion: nil, headerFields: nil)!
        
        let rawServiceError = RawServiceError(code: 20304, message: "")
        
        let response = Response(statusCode: statusCode, response: urlResponse, body: try! JSONEncoder().encode(rawServiceError))
        
        guard case .retryAuth = retry.retryChoice(for: request, with: response) else {
            XCTFail()
            return
        }
    }
    
    func test04__STC_46__retryChoice__status401Other__shouldTriggerAuthRetry() {
        let retry = ExpBackoffRetry()
        
        let request = try! ServiceRequest(url: self.url, method: .get)
        
        let statusCode = 401
        
        let urlResponse = HTTPURLResponse(url: self.url, statusCode: statusCode, httpVersion: nil, headerFields: nil)!
        
        let rawServiceError = RawServiceError(code: 20303, message: "")
        
        let response = Response(statusCode: statusCode, response: urlResponse, body: try! JSONEncoder().encode(rawServiceError))
        
        guard case .noRetry = retry.retryChoice(for: request, with: response) else {
            XCTFail()
            return
        }
    }
    
    func test05__STC_47__retryChoice__status400__shouldNotTriggerRetry() {
        let retry = ExpBackoffRetry()
        
        let request = try! ServiceRequest(url: self.url, method: .get)
        
        let statusCode = 400
        
        let urlResponse = HTTPURLResponse(url: self.url, statusCode: statusCode, httpVersion: nil, headerFields: nil)!
        
        let response = Response(statusCode: statusCode, response: urlResponse, body: nil)
        
        guard case .noRetry = retry.retryChoice(for: request, with: response) else {
            XCTFail()
            return
        }
    }
    
    func test06__STC_48__retryChoice__status200__shouldNotTriggerRetry() {
        let retry = ExpBackoffRetry()
        
        let request = try! ServiceRequest(url: self.url, method: .get)
        
        let statusCode = 200
        
        let urlResponse = HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: nil, headerFields: nil)!
        
        let response = Response(statusCode: statusCode, response: urlResponse, body: nil)
        
        guard case .noRetry = retry.retryChoice(for: request, with: response) else {
            XCTFail()
            return
        }
    }
}
