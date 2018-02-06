//
//  JwtBodyContent.swift
//  VirgilSDK
//
//  Created by Eugen Pivovarov on 1/9/18.
//  Copyright © 2018 VirgilSecurity. All rights reserved.
//

import Foundation

@objc(VSSJwtBodyContent) public class JwtBodyContent: NSObject, Serializable, Deserializable {
    @objc public let appId: String
    @objc public let identity: String
    @objc public let expiresAt: Int
    @objc public let issuedAt: Int
    @objc public let additionalData: [String: String]?

    private enum CodingKeys: String, CodingKey {
        case appId = "iss"
        case identity = "sub"
        case additionalData = "ada"
        case issuedAt = "iat"
        case expiresAt = "exp"
    }

    @objc public init(appId: String, identity: String, expiresAt: Date,
                      issuedAt: Date, additionalData: [String: String]? = nil) {
        self.appId = "virgil-" + appId
        self.identity = "identity-" + identity
        self.expiresAt = Int(expiresAt.timeIntervalSince1970)
        self.issuedAt = Int(issuedAt.timeIntervalSince1970)
        self.additionalData = additionalData

        super.init()
    }

    @objc public convenience init?(string: String) {
        guard let data = Data(base64UrlEncoded: string),
            let json = try? JSONSerialization.jsonObject(with: data, options: []) else { return nil }

        self.init(dict: json)
    }

    @objc public func getBase64Url() throws -> String {
        return try self.asJsonData().base64UrlEncoded()
    }
}
