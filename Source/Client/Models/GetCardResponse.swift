//
//  GetCardResponse.swift
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 2/12/18.
//  Copyright © 2018 VirgilSecurity. All rights reserved.
//

import Foundation

/// Represents response from CardClient's getCard function with RawSignedModel and whether or not card is outdated
@objc(VSSGetCardResponse) public final class GetCardResponse: NSObject {
    /// RawSignedModel of Virgil Card
    @objc public let rawCard: RawSignedModel
    /// True if Virgil Card is outdated, false - otherwise
    @objc public let isOutdated: Bool

    /// Initializer
    ///
    /// - Parameters:
    ///   - rawCard: `RawSignedModel` of Virgil Card
    ///   - isOutdated: Whether card is outdated or not
    public init(rawCard: RawSignedModel, isOutdated: Bool) {
        self.rawCard = rawCard
        self.isOutdated = isOutdated

        super.init()
    }
}
