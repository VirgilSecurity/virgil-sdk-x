//
// Copyright (C) 2015-2018 Virgil Security Inc.
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
/// - constructingUrl: constructing url of endpoint failed
/// - noBody: service response does not have body
/// - invalidJson: service response body is invalid json
@objc(VSSCardClientError) public enum CardClientError: Int, Error {
    case constructingUrl = 1
    case noBody = 2
    case invalidJson = 3
}

/// Represent card service error
@objc(VSSCardServiceError) public final class CardServiceError: NSObject, CustomNSError {
    /// Http status code
    @objc public let httpStatusCode: Int
    /// Recieved and decoded `RawServiceError`
    @objc public let rawServiceError: RawServiceError

    /// Initializer
    ///
    /// - Parameter rawServiceError: recieved and decoded rawServiceError
    @objc public init(httpStatusCode: Int, rawServiceError: RawServiceError) {
        self.httpStatusCode = httpStatusCode
        self.rawServiceError = rawServiceError
    }

    /// Error domain or Error instances thrown from Service
    @objc public static var errorDomain: String { return CardClient.serviceErrorDomain }
    /// Code of error
    @objc public var errorCode: Int { return self.rawServiceError.code }
    /// Provides info about the error. Error message can be recieve by NSLocalizedDescriptionKey
    @objc public var errorUserInfo: [String: Any] { return [NSLocalizedDescriptionKey: self.rawServiceError.message] }
}

/// Class representing operations with Virgil Cards service
@objc(VSSCardClient) open class CardClient: NSObject {
    /// Base URL for the Virgil Gateway
    @objc public let serviceUrl: URL
    /// HttpConnectionProtocol implementation to use for queries
    public let connection: HttpConnectionProtocol
    /// Default URL for service
    @objc public static let defaultURL = URL(string: "https://api.virgilsecurity.com")!
    /// Error domain for Error instances thrown from service
    @objc public static let serviceErrorDomain = "VirgilSDK.CardServiceErrorDomain"

    /// Initializes a new `CardClient` instance
    ///
    /// - Parameters:
    ///   - serviceUrl: URL of service client will use
    ///   - connection: custom HTTPConnection
    public init(serviceUrl: URL = CardClient.defaultURL, connection: HttpConnectionProtocol) {
        self.serviceUrl = serviceUrl
        self.connection = connection

        super.init()
    }

    /// Initializes a new `CardClient` instance
    @objc convenience public override init() {
        self.init(serviceUrl: CardClient.defaultURL)
    }

    /// Initializes a new `CardClient` instance
    ///
    /// - Parameter serviceUrl: URL of service client will use
    @objc convenience public init(serviceUrl: URL) {
        self.init(serviceUrl: serviceUrl, connection: HttpConnection())
    }

    internal func handleError(statusCode: Int, body: Data?) -> Error {
        if let body = body {
            if let rawServiceError = try? JSONDecoder().decode(RawServiceError.self, from: body) {
                return CardServiceError(httpStatusCode: statusCode, rawServiceError: rawServiceError)
            }
            else if let str = String(data: body, encoding: .utf8) {
                return NSError(domain: CardClient.serviceErrorDomain, code: statusCode,
                               userInfo: [NSLocalizedDescriptionKey: str])
            }
        }

        return NSError(domain: CardClient.serviceErrorDomain, code: statusCode)
    }

    internal func validateResponse(_ response: Response) throws {
        guard 200..<300 ~= response.statusCode else {
            throw self.handleError(statusCode: response.statusCode, body: response.body)
        }
    }

    internal func processResponse<T: Decodable>(_ response: Response) throws -> T {
        try self.validateResponse(response)

        guard let data = response.body else {
            throw CardClientError.noBody
        }

        let responseModel = try JSONDecoder().decode(T.self, from: data)

        return responseModel
    }
}
