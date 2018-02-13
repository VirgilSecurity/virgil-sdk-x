//
//  GetCardResponse.swift
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 2/12/18.
//  Copyright © 2018 VirgilSecurity. All rights reserved.
//

import Foundation

@objc(VSSGetCardResponse) public final class GetCardResponse: NSObject {
    @objc public let rawCard: RawSignedModel
    @objc public let isOutdated: Bool

    public init(rawCard: RawSignedModel, isOutdated: Bool) {
        self.rawCard = rawCard
        self.isOutdated = isOutdated

        super.init()
    }
}
