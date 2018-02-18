//
//  JwtSignatureContent.swift
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 2/16/18.
//  Copyright © 2018 VirgilSecurity. All rights reserved.
//

import Foundation

/// Class representing JWT Signature content
@objc(VSSJwtSignatureContent) public final class JwtSignatureContent: NSObject {
    /// Declares error types and codes
    ///
    /// - base64UrlStrIsInvalid: If given base64 string is invalid
    @objc(VSSJwtSignatureContentError) public enum JwtSignatureContentError: Int, Error {
        case base64UrlStrIsInvalid = 1
    }

    /// Signature date
    @objc public let signature: Data
    /// String representation
    @objc public let stringRepresentation: String

    /// Imports JwtBodyContent from base64Url encoded string
    ///
    /// - Parameter base64UrlEncoded: base64Url encoded string with JwtBodyContent
    /// - Throws: JwtBodyContentError.base64UrlStrIsInvalid If given base64 string is invalid
    @objc public init(base64UrlEncoded: String) throws {
        guard let data = Data(base64UrlEncoded: base64UrlEncoded) else {
            throw JwtSignatureContentError.base64UrlStrIsInvalid
        }

        self.signature = data
        self.stringRepresentation = base64UrlEncoded

        super.init()
    }

    /// Initializer
    ///
    /// - Parameter signature: Signature data
    @objc public init(signature: Data) {
        self.signature = signature
        self.stringRepresentation = signature.base64UrlEncodedString()

        super.init()
    }
}
