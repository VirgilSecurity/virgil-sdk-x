//
//  JwtSignatureContent.swift
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 2/16/18.
//  Copyright © 2018 VirgilSecurity. All rights reserved.
//

import Foundation

@objc(VSSJwtSignatureContent) public final class JwtSignatureContent: NSObject {
    @objc(VSSJwtSignatureContentError) public enum JwtSignatureContentError: Int, Error {
        case base64UrlStrIsInvalid = 1
    }
    
    @objc public let signature: Data
    @objc public let stringRepresentation: String
    
    @objc public init(base64UrlEncoded: String) throws {
        guard let data = Data(base64UrlEncoded: base64UrlEncoded) else {
            throw JwtSignatureContentError.base64UrlStrIsInvalid
        }
        
        self.signature = data
        self.stringRepresentation = base64UrlEncoded
        
        super.init()
    }
    
    @objc public init(signature: Data) {
        self.signature = signature
        self.stringRepresentation = signature.base64UrlEncodedString()
        
        super.init()
    }
}
