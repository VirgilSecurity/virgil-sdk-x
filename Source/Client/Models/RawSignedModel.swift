//
//  RawCard.swift
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 9/14/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

import Foundation

@objc(VSSRawSignedModel) public class RawSignedModel: NSObject, Codable {
    @objc public let contentSnapshot: Data
    @objc public var signatures: [RawSignature]
    
    private enum CodingKeys: String, CodingKey {
        case contentSnapshot = "content_snapshot"
        case signatures
    }
    
    @objc public init(contentSnapshot: Data, signatures: [RawSignature] = []) {
        self.contentSnapshot = contentSnapshot
        self.signatures      = signatures
        
        super.init()
    }
}
