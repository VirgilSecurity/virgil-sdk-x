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
import VirgilSDK
import XCTest

class VSS017_NetworkTests: XCTestCase {
    private var client: BaseClient!
    let url = URL(string: "https://example.com/")!
    
    override func setUp() {
        let crypto = try! VirgilCrypto()
        let consts = VSSTestsConst()
        let utils = VSSTestUtils(crypto: crypto, consts: consts)
        let generator = utils.getGeneratorJwtProvider(withIdentity: "identity", error: nil)
        
        self.client = BaseClient(accessTokenProvider: generator, serviceUrl: self.url)
    }
    
    func test01() {
        let exp = expectation(description: "")
        
        let request = try! ServiceRequest(url: self.url, method: .get)
        let connectionRetry = ExpBackoffRetry()
        
        let op = try! self.client.sendWithRetry(request, retry: connectionRetry, tokenContext: TokenContext(service: "", operation: ""))
        
        op.start() { result, error in
            XCTAssert(result == nil)
            XCTAssert(error != nil)
            
            do {
                throw error!
            }
            catch GenericOperationError.operationCancelled { }
            catch {
                XCTFail()
            }
            
            exp.fulfill()
        }
        
        op.cancel()
        
        self.wait(for: [exp], timeout: 15)
    }
}
