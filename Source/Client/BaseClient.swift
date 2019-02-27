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

/// Declares client error types and codes
///
/// - noBody: service response does not have body
@objc(VSSBaseClientError) public enum BaseClientError: Int, Error {
    case noBody = 1
}

/// Base class for clients
@objc(VSSBaseClient) open class BaseClient: NSObject {
    /// Base URL for a service
    @objc public let serviceUrl: URL
    /// HttpConnectionProtocol implementation to use for queries
    public let connection: HttpConnectionProtocol
    /// Error domain for Error instances thrown from service
    @objc open class var serviceErrorDomain: String { return "VirgilSDK.BaseServiceErrorDomain" }

    @objc public let accessTokenProvider: AccessTokenProvider
    
    public let requestRetryConfig: RequestRetry.Config

    /// Initializes a new `BaseClient` instance
    ///
    /// - Parameters:
    ///   - serviceUrl: URL of service client will use
    ///   - connection: custom HTTPConnection
    public init(accessTokenProvider: AccessTokenProvider,
                serviceUrl: URL,
                requestRetryConfig: RequestRetry.Config,
                connection: HttpConnectionProtocol) {
        self.accessTokenProvider = accessTokenProvider
        self.serviceUrl = serviceUrl
        self.requestRetryConfig = requestRetryConfig
        self.connection = connection

        super.init()
    }

    open func sendWithRetry(_ request: ServiceRequest, tokenContext: TokenContext) throws -> Response {
        let requestRetry = RequestRetry(config: self.requestRetryConfig)

        try self.setToken(for: request, tokenContext: tokenContext)

        let response = try { () -> Response in
            while true {
                let response = try self.connection.send(request)

                switch requestRetry.retryChoice(for: request, with: response) {
                case .noRetry:
                    return response

                case .retryService(let retryDelay):
                    Thread.sleep(forTimeInterval: retryDelay)

                case .retryAuth:
                    let retryTokenContext = TokenContext(identity: tokenContext.identity,
                                                         service: tokenContext.service,
                                                         operation: tokenContext.operation,
                                                         forceReload: true)

                    try self.setToken(for: request, tokenContext: retryTokenContext)
                }
            }
        }()

        return response
    }

    private func setToken(for request: ServiceRequest, tokenContext: TokenContext) throws {
        let token = try OperationUtils.makeGetTokenOperation(tokenContext: tokenContext,
                                                             accessTokenProvider: self.accessTokenProvider)
            .startSync()
            .getResult()

        request.setAccessToken(token.stringRepresentation())
    }

    /// Handles error
    ///
    /// - Parameters:
    ///   - statusCode: http status code
    ///   - body: response body
    /// - Returns: Corresponding error instance
    open func handleError(statusCode: Int, body: Data?) -> Error {
        if let body = body, let str = String(data: body, encoding: .utf8) {
            return NSError(domain: type(of: self).serviceErrorDomain,
                           code: statusCode,
                           userInfo: [NSLocalizedDescriptionKey: str])
        }

        return NSError(domain: type(of: self).serviceErrorDomain, code: statusCode)
    }

    /// Validated response and throws error if needed
    ///
    /// - Parameter response: response
    /// - Throws: NSError
    open func validateResponse(_ response: Response) throws {
        guard 200..<300 ~= response.statusCode else {
            throw self.handleError(statusCode: response.statusCode, body: response.body)
        }
    }

    /// Processes response and returns needed Decodable type
    ///
    /// - Parameter response: response
    /// - Returns: Decoded object of type T
    /// - Throws: BaseClientError.noBody if no body was found in response
    ///           Rethrows from JSONDecoder
    open func processResponse<T: Decodable>(_ response: Response) throws -> T {
        try self.validateResponse(response)

        guard let data = response.body else {
            throw BaseClientError.noBody
        }

        let responseModel = try JSONDecoder().decode(T.self, from: data)

        return responseModel
    }
}
