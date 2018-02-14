//
//  JWT.swift
//  VirgilSDK
//
//  Created by Eugen Pivovarov on 1/9/18.
//  Copyright © 2018 VirgilSecurity. All rights reserved.
//

import Foundation

/// Class implementing `AccessToken` in terms of JWT
/// - Important: [JWT specification](https://tools.ietf.org/html/rfc7519)
@objc(VSSJwt) public class Jwt: NSObject, AccessToken {
    /// Represents JWT Header content
    @objc public let headerContent: JwtHeaderContent
    /// Represents JWT Body content
    @objc public let bodyContent: JwtBodyContent
    /// Keeps string representation of unsigned token
    @objc public let unsignedString: String

    /// Keeps string representation of signed token
    @objc public private(set) var string: String
    /// Signature data
    @objc public private(set) var signatureContent: Data?

    /// Initializes `Jwt` with provided header, body and signature content
    ///
    /// - Parameters:
    ///   - headerContent: header of `Jwt`
    ///   - bodyContent: body of `Jwt`
    ///   - signatureContent: Data with signature content
    @objc public init?(headerContent: JwtHeaderContent, bodyContent: JwtBodyContent, signatureContent: Data? = nil) {
        self.headerContent = headerContent
        self.bodyContent = bodyContent
        self.signatureContent = signatureContent

        guard let headerBase64Url = try? self.headerContent.base64UrlEncodedString(),
              let bodyBase64Url = try? self.bodyContent.base64UrlEncodedString() else { return nil }

        var result = headerBase64Url + "." + bodyBase64Url
        self.unsignedString = result

        if let signatureContent = signatureContent {
            result += "." + signatureContent.base64UrlEncodedString()
        }
        self.string = result

        super.init()
    }

    /// Initializes `Jwt` from its string representation
    ///
    /// - Parameter stringRepresentation: must be equal to
    ///   base64UrlEncode(JWT Header) + "." + base64UrlEncode(JWT Body) + "." + base64UrlEncode(Jwt Signature)
    @objc public init?(stringRepresentation: String) {
        let array = stringRepresentation.components(separatedBy: ".")

        guard array.count >= 2 else {
            return nil
        }
        let headerBase64Url = array[0]
        let bodyBase64Url = array[1]

        guard let headerContent = JwtHeaderContent.importFrom(base64UrlEncoded: headerBase64Url),
              let bodyContent = JwtBodyContent.importFrom(base64UrlEncoded: bodyBase64Url) else { return nil }

        var signatureContent: Data? = nil
        if array.count == 3 {
            let signatureBase64Url = array[2]
            signatureContent = Data(base64UrlEncoded: signatureBase64Url)
        }
        self.headerContent = headerContent
        self.bodyContent = bodyContent
        self.signatureContent = signatureContent
        self.unsignedString = headerBase64Url + "." + bodyBase64Url
        self.string = stringRepresentation

        super.init()
    }

    /// Provides string representation of token
    ///
    /// - Returns: string representation of token
    @objc public func stringRepresentation() -> String {
        return self.string
    }

    /// Extracts identity
    ///
    /// - Returns: identity
    @objc public func identity() -> String {
        return self.bodyContent.identity
    }

    /// Returns whether or not token is expired
    ///
    /// - Returns: true if token is expired, false otherwise
    @objc public func isExpired() -> Bool {
        return Int(Date().timeIntervalSince1970) >= self.bodyContent.expiresAt
    }

    /// Sets signature content to JWT
    ///
    /// - Parameter signatureContent: sinature to be set
    /// - Throws: error if token corrupted
    public func setSignatureContent(_ signatureContent: Data) throws {
        self.signatureContent = signatureContent
        let headerBase64Url = try self.headerContent.base64UrlEncodedString()
        let bodyBase64Url = try self.bodyContent.base64UrlEncodedString()

        self.string = headerBase64Url + "." + bodyBase64Url + "." + signatureContent.base64UrlEncodedString()
    }
}
