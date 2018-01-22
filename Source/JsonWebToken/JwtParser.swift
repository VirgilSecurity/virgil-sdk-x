//
//  JwtParser.swift
//  VirgilSDK
//
//  Created by Eugen Pivovarov on 1/15/18.
//  Copyright © 2018 VirgilSecurity. All rights reserved.
//

import Foundation

@objc(VSSJwtParser) public class JwtParser: NSObject {
    
    @objc public enum JwtParserError: Int, Error {
        case bodyContentCorrupted
        case headerContentCorrupted
    }
    
    @objc public static func parseJwtBodyContent(jwtBody: String) throws -> JwtBodyContent {
        guard let data = Data(base64UrlEncoded: jwtBody) else {
            throw NSError()
        }
        let json = try JSONSerialization.jsonObject(with: data, options: [])
        
        guard let jwtBodyContent = JwtBodyContent(dict: json) else {
            throw JwtParserError.bodyContentCorrupted
        }
        
        return jwtBodyContent
    }
    
    @objc public static func buildJwtBody(jwtBodyContent: JwtBodyContent) throws -> String {
         return try jwtBodyContent.asString()
    }
    
    @objc public static func parseJwtHeaderContent(jwtHeader: String) throws -> JwtHeaderContent {
        guard let data = Data(base64UrlEncoded: jwtHeader) else {
            throw NSError()
        }
        let json = try JSONSerialization.jsonObject(with: data, options: [])
        
        guard let jwtHeaderContent = JwtHeaderContent(dict: json) else {
            throw JwtParserError.headerContentCorrupted
        }
        
        return jwtHeaderContent
    }
    
    @objc public static func buildJwtHeader(jwtHeaderContent: JwtHeaderContent) throws -> String {
        return try jwtHeaderContent.asString()
    }
}
