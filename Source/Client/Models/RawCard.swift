//
//  RawCard.swift
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 9/14/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

import Foundation

// FIXME
@objc(VSSRawCard) public class RawCard: NSObject, VSSDeserializable {
    public let contentSnapshot: Data
//    public let signatures:
    
    public required init?(dict candidate: [AnyHashable : Any]) {
        self.contentSnapshot = Data()
        
        super.init()
    }
}
