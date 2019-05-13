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
    
    func test01__cancel__should_be_cancelled() {
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
    
    func test02__network_retry__should_retry() {
        let request = try! ServiceRequest(url: self.url, method: .get)
        
        class FakeAccessToken: AccessToken {
            func stringRepresentation() -> String {
                return ""
            }
            
            func identity() -> String {
                return ""
            }
        }
        
        class FakeConnection: HttpConnectionProtocol {
            private var counter = 0
            
            func checkState() {
                XCTAssert(self.counter == 3)
            }
            
            func send(_ request: Request) throws -> GenericOperation<Response> {
                if (self.counter == 0 || self.counter == 1) {
                    self.counter += 1
                    return CallbackOperation { _, completion in
                        completion(nil, NSError(domain: NSURLErrorDomain, code: NSURLErrorCannotConnectToHost, userInfo: nil))
                    }
                }
                else if (self.counter == 2) {
                    self.counter += 1
                    let urlResponse = HTTPURLResponse(url: URL(string: "https://example.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)!
                    
                    return CallbackOperation { _, completion in
                        completion(Response(statusCode: 200, response: urlResponse, body: nil), nil)
                    }
                }
                
                XCTFail()
                throw NSError()
            }
        }
        
        class FakeReachability: ReachabilityProtocol {
            private var counter = 0
            
            func checkState() {
                XCTAssert(self.counter == 2)
            }
            
            func waitTillReachable(timeoutDate: Date, url: String) throws {
                self.counter += 1
                sleep(2)
            }
        }
        
        let reachability = FakeReachability()
        let connection = FakeConnection()
        
        
        let op = NetworkRetryOperation(request: request,
                                       retry: ExpBackoffRetry(),
                                       tokenContext: TokenContext(service: "", operation: ""),
                                       accessTokenProvider: ConstAccessTokenProvider(accessToken: FakeAccessToken()),
                                       connection: connection,
                                       reachability: reachability)
        
        do {
            _ = try op.startSync().getResult()
        }
        catch {
            XCTFail(error.localizedDescription)
        }
        
        reachability.checkState()
        connection.checkState()
    }
}
