//
//  CardSignature.swift
//  VirgilSDK
//
//  Created by Eugen Pivovarov on 1/11/18.
//  Copyright © 2018 VirgilSecurity. All rights reserved.
//

import Foundation

@objc(VSSCardSignature) public final class CardSignature: NSObject {
    @objc public let signer: String
    @objc public let signature: Data
    @objc public let snapshot: Data
    @objc public let extraFields: [String: String]?

    @objc public init(signer: String, signature: Data, snapshot: Data?, extraFields: [String: String]? = nil) {
        self.signer = signer
        self.signature = signature
        self.snapshot = snapshot ?? Data()
        self.extraFields = extraFields

        super.init()
    }
}
