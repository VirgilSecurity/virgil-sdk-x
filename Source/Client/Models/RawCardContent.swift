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
    @objc public let publicKey: String
    @objc public let previousCardId: String?
    @objc public let version: String
    @objc public let createdAt: Int
    
    private enum CodingKeys: String, CodingKey {
        case publicKey      = "public_key"
        case previousCardId = "previous_card_id"
        case createdAt      = "created_at"
        
        case identity
        case version
    }
    
    @objc public init(identity: String, publicKey: String, previousCardId: String? = nil, version: String? = nil, createdAt: Date) {
        self.identity = identity
        self.publicKey = publicKey
        self.previousCardId = previousCardId
        self.version = version ?? "5.0"
        self.createdAt = Int(createdAt.timeIntervalSince1970)
        
        super.init()
    }
    
    @objc public convenience init?(snapshot: Data) {
        guard let content: RawCardContent = SnapshotUtils.parseSnapshot(snapshot: snapshot) else { return nil }
        self.init(identity: content.identity, publicKey: content.publicKey, previousCardId: content.previousCardId, version: content.version, createdAt: Date(timeIntervalSince1970: TimeInterval(content.createdAt)))
    }
    
    
    @objc func snapshot() -> Data? {
        return try? SnapshotUtils.takeSnapshot(object: self)
    }
}
