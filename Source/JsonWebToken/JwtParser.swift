//
//  JwtParser.swift
//  VirgilSDK
//
//  Created by Eugen Pivovarov on 1/15/18.
//  Copyright © 2018 VirgilSecurity. All rights reserved.
//

import Foundation

@objc(VSSJwtParser) public class JwtParser: NSObject {
    @objc public static func parseJwtBodyContent(jwtBody: String) -> JwtBodyContent? {
        guard let data = Data(base64UrlEncoded: jwtBody),
              let json = try? JSONSerialization.jsonObject(with: data, options: []),
              let jwtBodyContent = JwtBodyContent(dict: json) else { return nil }
        
        return jwtBodyContent
    }
    
    @objc public static func buildJwtBody(jwtBodyContent: JwtBodyContent) throws -> String {
         return try jwtBodyContent.asString()
    }
    
    @objc public static func parseJwtHeaderContent(jwtHeader: String) -> JwtHeaderContent? {
        guard let data = Data(base64UrlEncoded: jwtHeader),
              let json = try? JSONSerialization.jsonObject(with: data, options: []),
              let jwtHeaderContent = JwtHeaderContent(dict: json) else { return nil }
        
        return jwtHeaderContent
    }
    
    @objc public static func buildJwtHeader(jwtHeaderContent: JwtHeaderContent) throws -> String {
        return try jwtHeaderContent.asString()
    }
}
