//
//  RawSignedModel.swift
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 9/14/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

import Foundation

/// Represents some model in binary form that can have signatures and corresponds to Virgil Cards Service model
@objc(VSSRawSignedModel) public final class RawSignedModel: NSObject, Codable {
    /// Snapshot of `RawCardContent`
    @objc public let contentSnapshot: Data
    /// Array with RawSignatures of card
    @objc public private(set) var signatures: [RawSignature]

    /// Defines coding keys for encoding and decoding
    private enum CodingKeys: String, CodingKey {
        case contentSnapshot = "content_snapshot"
        case signatures = "signatures"
    }

    /// Declares error types and codes
    ///
    /// - invalidBase64String: Passed string is not correct base64 encoded string
    /// - duplicateSignature: Signature with same signer already exists
    @objc(VSSRawSignedModelError) public enum RawSignedModelError: Int, Error {
        case invalidBase64String = 1
        case duplicateSignature = 2
    }

    /// Initializes a new `RawSignedModel` with the provided contentSnapshot
    ///
    /// - Parameter contentSnapshot: data with snapshot of content
    @objc public init(contentSnapshot: Data) {
        self.contentSnapshot = contentSnapshot
        self.signatures = []

        super.init()
    }

    /// Initializes `RawSignedModel` from json dictionary
    ///
    /// - Parameter json: Json-compatible dictionary
    /// - Returns: RawSignedModel instance
    /// - Throws: Rethrows from JSONDecoder and NSJSONSerialization
    @objc public static func `import`(fromJson json: Any) throws -> RawSignedModel {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])

        return try JSONDecoder().decode(RawSignedModel.self, from: data)
    }

    /// Initializes `RawSignedModel` from base64 encoded string
    ///
    /// - Parameter base64EncodedString: Base64 encoded string with `RawSignedModel`
    /// - Returns: RawSignedModel instance
    /// - Throws: RawSignedModelError.invalidBase64String if passed string is not base64 encoded data.
    ///           Rethrows from JSONDecoder
    @objc public static func `import`(fromBase64Encoded base64EncodedString: String) throws -> RawSignedModel {
        guard let data = Data(base64Encoded: base64EncodedString) else {
            throw RawSignedModelError.invalidBase64String
        }

        return try JSONDecoder().decode(RawSignedModel.self, from: data)
    }

    /// Exports `RawSignedModel` as base64 encoded string
    ///
    /// - Returns: Base64 encoded string with `RawSignedModel`
    /// - Throws: Rethrows from JSONEncoder
    @objc public func exportAsBase64EncodedString() throws -> String {
       return try JSONEncoder().encode(self).base64EncodedString()
    }

    /// Exports `RawSignedModel` as json dictionary
    ///
    /// - Returns: Json-compatible dictionary with `RawSignedModel`
    /// - Throws: Rethrows from JSONEncoder and JSONSerialization
    @objc public func exportAsJson() throws -> Any {
        let data = try JSONEncoder().encode(self)

        return try JSONSerialization.jsonObject(with: data, options: [])
    }

    /// Adds new signature
    ///
    /// - Parameter signature: signature to add
    /// - Throws: RawSignedModelError.duplicateSignature if signature with same signer already exists
    @objc public func addSignature(_ signature: RawSignature) throws {
        guard self.signatures.first(where: { $0.signer == signature.signer }) == nil else {
            throw RawSignedModelError.duplicateSignature
        }

        self.signatures.append(signature)
    }
}
