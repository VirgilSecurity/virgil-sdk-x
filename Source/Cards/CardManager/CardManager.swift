//
// Copyright (C) 2015-2020 Virgil Security Inc.
//
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are
// met:
//
//     (1) Redistributions of source code must retain the above copyright
//     notice, this list of conditions and the following disclaimer.
//
//     (2) Redistributions in binary form must reproduce the above copyright
//     notice, this list of conditions and the following disclaimer in
//     the documentation and/or other materials provided with the
//     distribution.
//
//     (3) Neither the name of the copyright holder nor the names of its
//     contributors may be used to endorse or promote products derived from
//     this software without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE AUTHOR ''AS IS'' AND ANY EXPRESS OR
// IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
// WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT,
// INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
// HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
// STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING
// IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.
//
// Lead Maintainer: Virgil Security Inc. <support@virgilsecurity.com>
//

import Foundation
import VirgilCrypto

/// Declares error types and codes for CardManager
///
/// - cardIsNotVerified: Virgil Card was not verified by cardVerifier
/// - gotWrongCard: Response Card doesn't match to what was queried
/// - chainWasRevoked: Virgil Card was revoked
@objc(VSSCardManagerError) public enum CardManagerError: Int, LocalizedError {
    case cardIsNotVerified = 1
    case gotWrongCard = 2
    case chainWasRevoked = 3

    /// Human-readable localized description
    public var errorDescription: String? {
        switch self {
        case .cardIsNotVerified:
            return "Virgil Card was not verified by cardVerifier"
        case .gotWrongCard:
            return "Response Card doesn't match to what was queried"
        case .chainWasRevoked:
            return "Virgil Card was revoked"
        }
    }
}

/// Class responsible for operations with Virgil Cards
@objc(VSSCardManager) open class CardManager: NSObject {
    /// ModelSigner instance used for self signing Cards
    @objc public let modelSigner: ModelSigner
    /// Crypto instance
    @objc public let crypto: VirgilCrypto
    /// CardClient instance used for performing queries
    @objc public let cardClient: CardClientProtocol
    /// Card Verifier instance used for verifying Cards
    @objc public let cardVerifier: CardVerifier
    /// Called to perform additional signatures for card before publishing
    @objc public let signCallback: ((RawSignedModel, @escaping (RawSignedModel?, Error?) -> Void) -> Void)?

    /// Initializer
    ///
    /// - Parameter params: CardManagerParams with needed parameters
    @objc public init(params: CardManagerParams) {
        self.modelSigner = params.modelSigner
        self.crypto = params.crypto
        self.cardClient = params.cardClient
        self.cardVerifier = params.cardVerifier
        self.signCallback = params.signCallback

        super.init()
    }
}
