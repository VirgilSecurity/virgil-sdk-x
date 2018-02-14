//
//  CardVerifier.swift
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 9/18/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

import Foundation
import VirgilCryptoAPI

/// Protocol representing Card verification process.
@objc(VSSCardVefifier) public protocol CardVerifier {

    /// Verifies Card instance
    ///
    /// - Parameter card: Card to verify
    /// - Returns: true if Card verified, false otherwise
    @objc func verifyCard(card: Card) -> Bool
}
