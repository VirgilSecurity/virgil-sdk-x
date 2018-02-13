//
//  CardClient.swift
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 9/14/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

import Foundation

/// Class representing operations with Virgil Cards service
@objc(VSSCardClient) open class CardClient: NSObject {
    @objc public let serviceUrl: URL
    public let connection: HttpConnectionProtocol

    /// Error domain for NSError instances thrown from service
    @objc public static let serviceErrorDomain = "VirgilSDK.CardServiceErrorDomain"
    /// Error domain for NSError instances thrown from here
    @objc public static let clientErrorDomain = "VirgilSDK.CardClientErrorDomain"

    @objc public static let defaultURL = URL(string: "https://api.virgilsecurity.com")!

    /// Declares client error types and codes
    ///
    /// - constructingUrl: constructing url of endpoint failed
    /// - noBody: service response does not have body
    /// - invalidJson: service response body is invalid json
    /// - invalidResponseModel: constructing returned `RawSignedModel` failed
    @objc public enum CardClientError: Int, CustomNSError {
        case constructingUrl = 1
        case noBody = 2
        case invalidJson = 3
        case invalidResponseModel = 4

        public static var errorDomain: String { return CardClient.clientErrorDomain }

        public var errorCode: Int { return self.rawValue }
    }

    /// Represent card service error
    @objc public class CardServiceError: NSObject, CustomNSError {
        public let rawServiceError: RawServiceError

        public init(rawServiceError: RawServiceError) {
            self.rawServiceError = rawServiceError
        }

        public static var errorDomain: String { return CardClient.serviceErrorDomain }

        public var errorCode: Int { return self.rawServiceError.code }

        public var errorUserInfo: [String: Any] { return [NSLocalizedDescriptionKey: self.rawServiceError.message] }
    }

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
    ///
    /// - Parameter serviceUrl: URL of service client will use
    @objc convenience public init(serviceUrl: URL = defaultURL) {
        self.init(serviceUrl: serviceUrl, connection: HttpConnection())
    }

    internal func handleError(statusCode: Int, body: Data?) -> Error {
        if let body = body {
            if let rawServiceError = try? JSONDecoder().decode(RawServiceError.self, from: body) {
                    return CardServiceError(rawServiceError: rawServiceError)
            }
            else if let str = String(data: body, encoding: .utf8) {
                return NSError(domain: CardClient.serviceErrorDomain, code: statusCode,
                               userInfo: [NSLocalizedDescriptionKey: str])
            }
        }

        return NSError(domain: CardClient.serviceErrorDomain, code: statusCode)
    }

    private func validateResponse(_ response: Response) throws {
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
