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

extension CardManager {
    /// Imports Virgil Card from RawSignedModel
    ///
    /// - Parameters:
    ///   - crypto: `Crypto` instance
    ///   - rawSignedModel: RawSignedModel to import
    /// - Returns: imported Card
    /// - Throws: corresponding error
    @objc open class func parseCard(from rawSignedModel: RawSignedModel, crypto: VirgilCrypto) throws -> Card {
        let contentSnapshot = rawSignedModel.contentSnapshot
        let rawCardContent = try JSONDecoder().decode(RawCardContent.self, from: contentSnapshot)

        guard let publicKeyData = rawCardContent.publicKey else {
            throw CardManagerError.chainWasRevoked
        }

        let publicKey = try crypto.importPublicKey(from: publicKeyData)
        let fingerprint = crypto.computeHash(for: rawSignedModel.contentSnapshot, using: .sha512)
        let cardId = fingerprint.subdata(in: 0..<32).hexEncodedString()

        var cardSignatures: [CardSignature] = []
        for rawSignature in rawSignedModel.signatures {
            let extraFields: [String: String]?

            if let rawSnapshot = rawSignature.snapshot,
                let json = try? JSONSerialization.jsonObject(with: rawSnapshot, options: []),
                let result = json as? [String: String] {
                extraFields = result
            }
            else {
                extraFields = nil
            }

            let cardSignature = CardSignature(signer: rawSignature.signer,
                                              signature: rawSignature.signature,
                                              snapshot: rawSignature.snapshot,
                                              extraFields: extraFields)

            cardSignatures.append(cardSignature)
        }

        let createdAt = DateUtils.dateFromTimestamp(rawCardContent.createdAt)

        return Card(identifier: cardId,
                    identity: rawCardContent.identity,
                    publicKey: publicKey,
                    version: rawCardContent.version,
                    createdAt: createdAt,
                    signatures: cardSignatures,
                    previousCardId: rawCardContent.previousCardId,
                    contentSnapshot: rawSignedModel.contentSnapshot)
    }

    /// Imports Virgil Card from RawSignedModel using self Crypto instance
    ///
    /// - Parameters:
    ///   - rawSignedModel: RawSignedModel to import
    /// - Returns: imported Card
    /// - Throws: corresponding error
    @objc open func parseCard(from rawSignedModel: RawSignedModel) throws -> Card {
        return try CardManager.parseCard(from: rawSignedModel, crypto: self.crypto)
    }
}
