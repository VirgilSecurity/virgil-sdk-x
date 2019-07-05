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
import VirgilCrypto
import VirgilSDK

enum TestId {
    case test01
    case test02
    case test03
}

class ConnectionRetryMock: HttpConnectionProtocol, RetryProtocol {
    private var requestCount = 0
    private let testId: TestId
    private let response = Response(statusCode: 200, response: HTTPURLResponse(), body: nil)
    
    init(testId: TestId) {
        self.testId = testId
    }
    
    func retryChoice(for request: ServiceRequest, with error: Error) -> RetryChoice {
        fatalError()
    }
    
    func retryChoice(for request: ServiceRequest, with response: Response) -> RetryChoice {
        switch self.testId {
        case .test01:
            return .noRetry
        case .test02:
            return self.requestCount <= 2 ? .retryService(delay: 1) : .noRetry
        case .test03:
            return self.requestCount <= 1 ? .retryAuth : .noRetry
        }
    }

    func send(_ request: Request) throws -> GenericOperation<Response> {
        self.requestCount += 1
        
        return CallbackOperation { _, completion in
            completion(self.response, nil)
        }
    }
    
    func checkFinishState() -> Bool {
        switch self.testId {
        case .test01:
            return self.requestCount == 1
            
        case .test02:
            return self.requestCount == 3
            
        case .test03:
            return self.requestCount == 2
        }
    }
}

class VSS016_ClientIntegrationRetryTests: XCTestCase {
    private var baseUrl: URL!
    private var accessTokenProvider: AccessTokenProvider!
    private var request: ServiceRequest!
    
    override func setUp() {
        self.baseUrl = URL(string: "https://example.com")!
        
        let utils = TestUtils.readFromBundle()
        self.accessTokenProvider = utils.getGeneratorJwtProvider(withIdentity: "identity")
        self.request = try! ServiceRequest(url: self.baseUrl, method: .post)
    }
    
    func test01__STC_49__client_retry__no_retry__should_not_retry() {
        let connectionRetry = ConnectionRetryMock(testId: .test01)
        let client = BaseClient(accessTokenProvider: self.accessTokenProvider, serviceUrl: self.baseUrl, connection: connectionRetry)
        
        do {
            _ = try client.sendWithRetry(self.request, retry: connectionRetry, tokenContext: TokenContext(service: "", operation: "")).startSync().getResult()
        }
        catch {
            XCTFail()
        }
        
        XCTAssert(connectionRetry.checkFinishState())
    }
    
    func test02__STC_50__client_retry__retry_service__should_retry() {
        let connectionRetry = ConnectionRetryMock(testId: .test02)
        let client = BaseClient(accessTokenProvider: self.accessTokenProvider, serviceUrl: self.baseUrl, connection: connectionRetry)
        
        do {
            _ = try client.sendWithRetry(self.request, retry: connectionRetry, tokenContext: TokenContext(service: "", operation: "")).startSync().getResult()
        }
        catch {
            XCTFail()
        }
        
        XCTAssert(connectionRetry.checkFinishState())
    }
    
    func test03__STC_51__client_retry__retry_auth__should_retry() {
        let connectionRetry = ConnectionRetryMock(testId: .test03)
        let client = BaseClient(accessTokenProvider: self.accessTokenProvider, serviceUrl: self.baseUrl, connection: connectionRetry)
        
        do {
            _ = try client.sendWithRetry(self.request, retry: connectionRetry, tokenContext: TokenContext(service: "", operation: "")).startSync().getResult()
        }
        catch {
            XCTFail()
        }
        
        XCTAssert(connectionRetry.checkFinishState())
    }
}
