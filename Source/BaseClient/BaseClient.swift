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

/// Declares client error types and codes
///
/// - noBody: service response does not have body
@objc(VSSBaseClientError) public enum BaseClientError: Int, LocalizedError {
    case noBody = 1

    /// Human-readable localized description
    public var errorDescription: String? {
        switch self {
        case .noBody:
            return "Service response does not have body"
        }
    }
}

/// Base class for clients
@objc(VSSBaseClient) open class BaseClient: NSObject {
    /// Base URL for a service
    @objc public let serviceUrl: URL
    /// HttpConnectionProtocol implementation to use for queries
    public let connection: HttpConnectionProtocol
    /// Error domain for Error instances thrown from service
    @objc open class var serviceErrorDomain: String { return ServiceError.errorDomain }
    /// Access token provider
    @objc public let accessTokenProvider: AccessTokenProvider

    /// Initializes new `BaseClient` instance
    ///
    /// - Parameters:
    ///   - accessTokenProvider: Access token provider
    ///   - serviceUrl: service url
    ///   - connection: Http Conntection
    public init(accessTokenProvider: AccessTokenProvider,
                serviceUrl: URL,
                connection: HttpConnectionProtocol = HttpConnection()) {
        self.accessTokenProvider = accessTokenProvider
        self.serviceUrl = serviceUrl
        self.connection = connection

        super.init()
    }

    /// Sends request and performs retries if needed
    ///
    /// - Parameters:
    ///   - request: request to send
    ///   - retry: Retry
    ///   - tokenContext: token context to forward to Access Token Provider
    /// - Returns: Response
    /// - Throws:
    ///   - Rethrows from `AccessTokenProvider`
    ///   - Rethrows from `HttpConnection`
    open func sendWithRetry(_ request: ServiceRequest,
                            retry: RetryProtocol,
                            tokenContext: TokenContext) throws -> GenericOperation<Response> {
        return NetworkRetryOperation(request: request,
                                     retry: retry,
                                     tokenContext: tokenContext,
                                     accessTokenProvider: self.accessTokenProvider,
                                     connection: self.connection)
    }

    private func setToken(for request: ServiceRequest, tokenContext: TokenContext) throws {
        let token = try OperationUtils.makeGetTokenOperation(tokenContext: tokenContext,
                                                             accessTokenProvider: self.accessTokenProvider)
            .startSync()
            .get()

        request.setAccessToken(token.stringRepresentation())
    }

    /// Handles error
    ///
    /// - Parameters:
    ///   - statusCode: http status code
    ///   - body: response body
    /// - Returns:
    ///   - ServiceError if service responded with correct error json
    ///   - NSError with http response string in the description, if present
    ///   - NSError without description in case of empty response
    open func handleError(statusCode: Int, body: Data?) -> Error {
        if let body = body {
            if let rawServiceError = try? JSONDecoder().decode(RawServiceError.self, from: body) {
                return ServiceError(httpStatusCode: statusCode,
                                    rawServiceError: rawServiceError,
                                    errorDomain: type(of: self).serviceErrorDomain)
            }
            else if let string = String(data: body, encoding: .utf8) {
                return NSError(domain: type(of: self).serviceErrorDomain,
                               code: statusCode,
                               userInfo: [NSLocalizedDescriptionKey: string])
            }
        }

        return NSError(domain: type(of: self).serviceErrorDomain,
                       code: statusCode,
                       userInfo: [NSLocalizedDescriptionKey: "Unknown service error"])
    }

    /// Validated response and throws error if needed
    ///
    /// - Parameter response: response
    /// - Throws: See BaseClient.handleError
    open func validateResponse(_ response: Response) throws {
        guard 200..<300 ~= response.statusCode else {
            throw self.handleError(statusCode: response.statusCode, body: response.body)
        }
    }

    /// Processes response and returns needed Decodable type
    ///
    /// - Parameter response: response
    /// - Returns: Decoded object of type T
    /// - Throws:
    ///   - BaseClientError.noBody if body was not found in the response
    ///   - Rethrows from `JSONDecoder`
    open func processResponse<T: Decodable>(_ response: Response) throws -> T {
        try self.validateResponse(response)

        guard let data = response.body else {
            throw BaseClientError.noBody
        }

        let responseModel = try JSONDecoder().decode(T.self, from: data)

        return responseModel
    }
}
