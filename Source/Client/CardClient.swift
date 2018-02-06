//
//  CardClient.swift
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 9/14/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

import Foundation

@objc(VSSCardClient) public class CardClient: NSObject {
    @objc public let serviceUrl: URL
    @objc public let connection: HTTPConnection

    @objc public static let serviceErrorDomain = "VirgilSDK.CardServiceErrorDomain"
    @objc public static let clientErrorDomain = "VirgilSDK.CardClientErrorDomain"
    @objc public static let defaultURL = URL(string: "https://api.virgilsecurity.com")!

    @objc public enum CardClientError: Int, CustomNSError {
        case constructingUrl = 1
        case noBody = 2
        case invalidJson = 3
        case invalidResponseModel = 4

        public static var errorDomain: String { return CardClient.clientErrorDomain }

        public var errorCode: Int { return self.rawValue }
    }

    @objc public class CardServiceError: NSObject, CustomNSError {
        public let rawServiceError: RawServiceError

        public init(rawServiceError: RawServiceError) {
            self.rawServiceError = rawServiceError
        }

        public static var errorDomain: String { return CardClient.serviceErrorDomain }

        public var errorCode: Int { return self.rawServiceError.code }

        public var errorUserInfo: [String: Any] { return [NSLocalizedDescriptionKey: self.rawServiceError.message] }
    }

    @objc convenience public init(serviceUrl: URL = defaultURL) {
        self.init(connection: ServiceConnection())
    }

    @objc public init(serviceUrl: URL = defaultURL, connection: HTTPConnection) {
        self.serviceUrl = serviceUrl
        self.connection = connection

        super.init()
    }

    internal func handleError(statusCode: Int, body: Data?) -> Error {
        if let body = body {
            if let json = try? JSONSerialization.jsonObject(with: body, options: []),
                let rawServiceError = RawServiceError(dict: json) {
                    return CardServiceError(rawServiceError: rawServiceError)
            }
            else if let str = String(data: body, encoding: .utf8) {
                return NSError(domain: CardClient.serviceErrorDomain, code: statusCode,
                               userInfo: [NSLocalizedDescriptionKey: str])
            }
        }

        return NSError(domain: CardClient.serviceErrorDomain, code: statusCode)
    }

    private func parseResponse(_ response: HTTPResponse) throws -> Any {
        guard let data = response.body else {
            throw CardClientError.noBody
        }

        guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
            throw CardClientError.invalidJson
        }

        return json
    }

    private func validateResponse(_ response: HTTPResponse) throws {
        guard response.statusCode / 100 == 2 else {
            throw self.handleError(statusCode: response.statusCode, body: response.body)
        }
    }

    internal func processResponse<T: Deserializable>(_ response: HTTPResponse) throws -> T {
        try self.validateResponse(response)

        let json = try self.parseResponse(response)

        guard let responseModel = T(dict: json) else {
            throw CardClientError.invalidResponseModel
        }

        return responseModel
    }
}
