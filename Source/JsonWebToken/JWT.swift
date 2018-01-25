//
//  JWT.swift
//  VirgilSDK
//
//  Created by Eugen Pivovarov on 1/9/18.
//  Copyright © 2018 VirgilSecurity. All rights reserved.
//

import Foundation

@objc(VSSJwt) public class Jwt: NSObject, AccessToken {
    private let headerContent: JwtHeaderContent
    private let bodyContent: JwtBodyContent
    
    @objc private(set) var signatureContent: Data?
    
    @objc public enum JwtError: Int, Error {
        case dataFromStringFailed
    }
    
    @objc public init(headerContent: JwtHeaderContent, bodyContent: JwtBodyContent, signatureContent: Data? = nil) {
        self.headerContent = headerContent
        self.bodyContent = bodyContent
        self.signatureContent = signatureContent
        
        super.init()
    }
    
    @objc public convenience init?(jwtToken: String) {
        let array = jwtToken.components(separatedBy: ".")
        
        guard let headerBase64Url    = array[safe: 0],
              let bodyBase64Url      = array[safe: 1],
              let headerContent = JwtParser.parseJwtHeaderContent(jwtHeader: headerBase64Url),
              let bodyContent   = JwtParser.parseJwtBodyContent(jwtBody: bodyBase64Url) else { return nil }
        
        var signatureContent: Data? = nil
        
        if let signatureBase64Url = array[safe: 2] {
            signatureContent = Data(base64UrlEncoded: signatureBase64Url)
        }
        
        self.init(headerContent: headerContent, bodyContent: bodyContent, signatureContent: signatureContent)
    }
    
    @objc public func stringRepresentation() throws -> String {
        let headerBase64Url = try JwtParser.buildJwtHeader(jwtHeaderContent: self.headerContent)
        let bodyBase64Url = try JwtParser.buildJwtBody(jwtBodyContent: self.bodyContent)
        
        var result = headerBase64Url + "." + bodyBase64Url
        if let signatureContent = self.signatureContent {
            result += "." + signatureContent.base64UrlEncoded()
        }
        
        return result
    }
    
    public func snapshotWithoutSignatures() throws -> Data {
        let headerBase64Url = try JwtParser.buildJwtHeader(jwtHeaderContent: self.headerContent)
        let bodyBase64Url = try JwtParser.buildJwtBody(jwtBodyContent: self.bodyContent)
        
        let string: String = headerBase64Url + "." + bodyBase64Url
        
        guard let data = string.data(using: .utf8) else {
            throw JwtError.dataFromStringFailed
        }
        
        return data
    }
    
    @objc public func identity() -> String {
        return self.bodyContent.identity
    }
    
    @objc public func isExpired() -> Bool {
        return Date() >= self.bodyContent.expiresAt
    }
    
    public func setSignatureContent(_ signatureContent: Data) {
        self.signatureContent = signatureContent
    }
}

