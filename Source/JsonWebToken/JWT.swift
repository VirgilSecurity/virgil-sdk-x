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
    private let signatureContent: Data
    
    @objc public init(headerContent: JwtHeaderContent, bodyContent: JwtBodyContent, signatureContent: Data) {
        self.headerContent = headerContent
        self.bodyContent = bodyContent
        self.signatureContent = signatureContent
    }
    
    @objc public func stringRepresentation() -> String {
        let headerBase64Url = (self.headerContent.serialize() as! Data).base64UrlEncoded()
        let bodyBase64Url = (self.bodyContent.serialize() as! Data).base64UrlEncoded()
        let signatureBase64Url = self.signatureContent.base64UrlEncoded()
        
        return headerBase64Url + "." + bodyBase64Url + "." + signatureBase64Url
    }
    
    @objc public func identity() -> String {
        return self.bodyContent.identity
    }
    
    @objc public func isExpired() -> Bool {
        return Date() >= self.bodyContent.expiresAt
    }
    
    
}

