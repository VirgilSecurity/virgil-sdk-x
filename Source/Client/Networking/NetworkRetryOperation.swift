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
import SystemConfiguration

open class NetworkRetryOperation: GenericOperation<Response> {
    public private(set) var lastNetworkOperation: GenericOperation<Response>?
    
    public let request: ServiceRequest
    public let retry: RetryProtocol
    public let tokenContext: TokenContext
    public let accessTokenProvider: AccessTokenProvider
    public let connection: HttpConnectionProtocol
    
    public init(request: ServiceRequest,
                retry: RetryProtocol,
                tokenContext: TokenContext,
                accessTokenProvider: AccessTokenProvider,
                connection: HttpConnectionProtocol) {
        self.request = request
        self.retry = retry
        self.tokenContext = tokenContext
        self.accessTokenProvider = accessTokenProvider
        self.connection = connection
        
        super.init()
    }
    
    open override func main() {
        do {
            guard !self.isCancelled else {
                self.finish()
                return
            }
            
            let response = try { () -> Response? in
                var tokenContext = self.tokenContext
                
                while true {
                    let token = try OperationUtils.makeGetTokenOperation(tokenContext: tokenContext,
                                                                         accessTokenProvider: self.accessTokenProvider)
                        .startSync()
                        .getResult()
                    
                    guard !self.isCancelled else {
                        self.finish()
                        return nil
                    }
                    
                    self.request.setAccessToken(token.stringRepresentation())

                    let lastNetworkOperation = try self.connection.send(self.request)
                    self.lastNetworkOperation = lastNetworkOperation
                    
                    guard !self.isCancelled else {
                        self.finish()
                        return nil
                    }
                    
                    let result = lastNetworkOperation.startSync()
                    
                    let retryChoice: RetryChoice
                    
                    switch result {
                    case .success(let response):
                        retryChoice = self.retry.retryChoice(for: self.request, with: response)
                        
                    case .failure(let error):
                        retryChoice = self.retry.retryChoice(for: self.request, with: error)
                    }
                    
                    switch retryChoice {
                    case .noRetry:
                        return try result.getResult()
                        
                    case .retryService(let retryDelay):
                        Log.debug("Retrying request to \(request.url.absoluteString) in \(retryDelay) s")
                        Thread.sleep(forTimeInterval: retryDelay)
                        Log.debug("Retrying request to \(request.url.absoluteString)")
                        
                    case .retryAuth:
                        Log.debug("Retrying request to \(request.url.absoluteString) with new auth")
                        tokenContext = TokenContext(identity: tokenContext.identity,
                                                             service: tokenContext.service,
                                                             operation: tokenContext.operation,
                                                             forceReload: true)
                        
                    case .retryConnection:
                        guard let reachibility = SCNetworkReachabilityCreateWithName(nil, request.url.absoluteString) else {
                            throw NSError() // FIXME
                        }
                        
                        var flags = SCNetworkReachabilityFlags()
                        guard SCNetworkReachabilityGetFlags(reachibility, &flags) else {
                            throw NSError() // FIXME
                        }
                        
                        // FIXME
                        break
                    }
                }
            }()
            
            if let response = response {
                self.result = .success(response)
                self.finish()
            }
        }
        catch {
            self.result = .failure(error)
            self.finish()
        }
    }
    
    open override func cancel() {
        super.cancel()
        
        self.lastNetworkOperation?.cancel()
    }
}
