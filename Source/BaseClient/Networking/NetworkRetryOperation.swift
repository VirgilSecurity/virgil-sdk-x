//
// Copyright (C) 2015-2020 Virgil Security Inc.
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

/// NetworkRetryOperation errors
///
/// - timeout: timeout
/// - reachabilityError: SCNetworkReachability returned error
public enum NetworkRetryOperationError: LocalizedError {
    case timeout
    case reachabilityError

    /// Human-readable localized description
    public var errorDescription: String? {
        switch self {
        case .timeout:
            return "Timeout has fired"
        case .reachabilityError:
            return "SCNetworkReachability returned error"
        }
    }
}

/// Class for network operation with retry
open class NetworkRetryOperation: GenericOperation<Response> {

    /// Last network operations
    public private(set) var lastNetworkOperation: GenericOperation<Response>?

    /// Timeout for whole operation with retries
    static let timeout: TimeInterval = 120

    /// Request
    public let request: ServiceRequest

    /// Retry
    public let retry: RetryProtocol

    /// Token context
    public let tokenContext: TokenContext

    /// Access Token Provider
    public let accessTokenProvider: AccessTokenProvider

    /// Conntection
    public let connection: HttpConnectionProtocol

    /// Token
    public private(set) var token: AccessToken? = nil

    /// Reachability
    public let reachability: ReachabilityProtocol

    /// Initializer
    ///
    /// - Parameters:
    ///   - request: request
    ///   - retry: retry
    ///   - tokenContext: token context
    ///   - accessTokenProvider: access token provider
    ///   - connection: connection
    public init(request: ServiceRequest,
                retry: RetryProtocol,
                tokenContext: TokenContext,
                accessTokenProvider: AccessTokenProvider,
                connection: HttpConnectionProtocol,
                reachability: ReachabilityProtocol? = nil) {
        self.request = request
        self.retry = retry
        self.tokenContext = tokenContext
        self.accessTokenProvider = accessTokenProvider
        self.connection = connection
        self.reachability = reachability ?? Reachability()

        super.init()
    }

    /// Main
    override open func main() {
        guard !self.isCancelled else {
            self.finish()
            return
        }

        var now = Date()

        let timeoutDate = now.addingTimeInterval(NetworkRetryOperation.timeout)

        var forceRefreshToken = true

        do {
            let response = try { () -> Response? in
                var tokenContext = self.tokenContext

                while true {
                    guard !self.isCancelled else {
                        return nil
                    }

                    guard now < timeoutDate else {
                        Log.debug("Request to \(request.url.absoluteString) timeout")
                        throw NetworkRetryOperationError.timeout
                    }

                    let tokenExpired: Bool

                    if let oldToken = self.token, let jwt = oldToken as? Jwt {
                        tokenExpired = jwt.isExpired(date: now)
                    }
                    else {
                        tokenExpired = false
                    }

                    if forceRefreshToken || tokenExpired {
                        let token = try OperationUtils
                            .makeGetTokenOperation(tokenContext: tokenContext,
                                                   accessTokenProvider: self.accessTokenProvider)
                            .startSync()
                            .get()

                        guard !self.isCancelled else {
                            return nil
                        }

                        now = Date()

                        guard now < timeoutDate else {
                            Log.debug("Request to \(request.url.absoluteString) timeout")
                            throw NetworkRetryOperationError.timeout
                        }

                        self.request.setAccessToken(token.stringRepresentation())
                        self.token = token
                    }

                    let lastNetworkOperation = try self.connection.send(self.request)
                    self.lastNetworkOperation = lastNetworkOperation

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
                        return try result.get()

                    case .retryService(let retryDelay):
                        Log.debug("Retrying request to \(request.url.absoluteString) in \(retryDelay) s")

                        guard now.addingTimeInterval(retryDelay) < timeoutDate else {
                            Log.debug("Request to \(request.url.absoluteString) timeout")
                            throw NetworkRetryOperationError.timeout
                        }

                        Thread.sleep(forTimeInterval: retryDelay)
                        Log.debug("Retrying request to \(request.url.absoluteString)")

                        forceRefreshToken = false

                    case .retryAuth:
                        Log.debug("Retrying request to \(request.url.absoluteString) with new auth")
                        tokenContext = TokenContext(identity: tokenContext.identity,
                                                    service: tokenContext.service,
                                                    operation: tokenContext.operation,
                                                    forceReload: true)
                        forceRefreshToken = true

                    case .retryConnection:
                        Log.debug("Retrying request to \(request.url.absoluteString) due to connection problems")

                        try self.reachability.waitTillReachable(timeoutDate: timeoutDate,
                                                                url: request.url.absoluteString)

                        forceRefreshToken = false
                    }

                    now = Date()
                }
            }()

            if let response = response {
                self.result = .success(response)
            }
        }
        catch {
            self.result = .failure(error)
        }

        self.finish()
    }

    /// Cancel
    override open func cancel() {
        self.lastNetworkOperation?.cancel()

        super.cancel()
    }
}
