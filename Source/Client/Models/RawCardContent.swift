//
//  RawCardContent.swift
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 9/15/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

import Foundation

@objc(VSSRawCardContent) public class RawCardContent: NSObject, Codable {
    @objc public let identity: String
    @objc public let publicKeyData: Data
    @objc public let previousCardId: String?
    @objc public let version: String
    @objc public let createdAt: Date
    
    private enum CodingKeys: String, CodingKey {
        case publicKeyData  = "public_key"
        case previousCardId = "previous_card_id"
        case createdAt      = "created_at"
        
        case identity
        case version
    }
    
    init(identity: String, publicKeyData: Data, previousCardId: String?, version: String, createdAt: Date) {
        self.identity = identity
        self.publicKeyData = publicKeyData
        self.previousCardId = previousCardId
        self.version = version
        self.createdAt = createdAt
        
        super.init()
    }
}
