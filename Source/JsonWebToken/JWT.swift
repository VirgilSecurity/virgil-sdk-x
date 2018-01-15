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
        
        super.init()
    }
    
    @objc public convenience init?(jwtToken: String) {
        let array = jwtToken.components(separatedBy: ".")
        
        guard let headerBase64Url    = array[safe: 0],
              let bodyBase64Url      = array[safe: 1],
              let signatureBase64Url = array[safe: 2] else
        {
            return nil
        }
        
        do {
            let headerContent = try JwtParser.parseJwtHeaderContent(jwtHeader: headerBase64Url)
            let bodyContent   = try JwtParser.parseJwtBodyContent(jwtBody: bodyBase64Url)
            let signatureContent = try Data(base64UrlEncoded: signatureBase64Url)
            
            self.init(headerContent: headerContent, bodyContent: bodyContent, signatureContent: signatureContent)
        } catch {
            return nil
        }
    }
    
    @objc public func stringRepresentation() -> String {
        let headerBase64Url = JwtParser.buildJwtHeader(jwtHeaderContent: self.headerContent)
        let bodyBase64Url = JwtParser.buildJwtBody(jwtBodyContent: self.bodyContent)
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

