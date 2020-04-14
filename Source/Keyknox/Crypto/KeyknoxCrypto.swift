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
import VirgilCryptoFoundation

/// Declares error types and codes for KeyknoxCrypto
///
/// - decryptionFailed: Decryption failed
/// - emptyPublicKeysList: Public keys list is empty
/// - emptyData: Trying to encrypt empty data
@objc(VSSKeyknoxCryptoError) public enum KeyknoxCryptoError: Int, LocalizedError {
    case decryptionFailed = 3
    case emptyPublicKeysList = 4
    case emptyData = 5

    /// Human-readable localized description
    public var errorDescription: String? {
        switch self {
        case .decryptionFailed:
            return "Decryption failed"
        case .emptyPublicKeysList:
            return "Public keys list is empty"
        case .emptyData:
            return "Trying to encrypt empty data"
        }
    }
}

/// KeyknoxCryptoProtocol implementation using VirgilCrypto
open class KeyknoxCrypto {
    /// VirgilCrypto
    public let crypto: VirgilCrypto

    /// Init
    ///
    /// - Parameter crypto: VirgilCrypto instance
    public init(crypto: VirgilCrypto) {
        self.crypto = crypto
    }
}

// MARK: - KeyknoxCryptoProtocol implementation
extension KeyknoxCrypto: KeyknoxCryptoProtocol {
    /// Decrypts EncryptedKeyknoxValue
    ///
    /// - Parameters:
    ///   - encryptedKeyknoxValue: encrypted value from Keyknox service
    ///   - privateKey: private key to decrypt data. Should be of type VirgilPrivateKey
    ///   - publicKeys: allowed public keys to verify signature. Should be of type VirgilPublicKey
    /// - Returns: DecryptedKeyknoxValue
    /// - Throws:
    ///   - `KeyknoxCryptoError.emptyPublicKeysList` is public keys list is empty
    ///   - `KeyknoxManagerError.decryptionFailed` if decryption failed
    ///   - Rethrows from `VirgilCrypto`
    open func decrypt(encryptedKeyknoxValue: EncryptedKeyknoxValue,
                      privateKey: VirgilPrivateKey,
                      publicKeys: [VirgilPublicKey]) throws -> DecryptedKeyknoxValue {
        guard !publicKeys.isEmpty else {
            throw KeyknoxCryptoError.emptyPublicKeysList
        }

        if encryptedKeyknoxValue.value.isEmpty && encryptedKeyknoxValue.meta.isEmpty {
            return DecryptedKeyknoxValue(root: encryptedKeyknoxValue.root,
                                         path: encryptedKeyknoxValue.path,
                                         key: encryptedKeyknoxValue.key,
                                         owner: encryptedKeyknoxValue.owner,
                                         identities: encryptedKeyknoxValue.identities,
                                         meta: Data(),
                                         value: Data(),
                                         keyknoxHash: encryptedKeyknoxValue.keyknoxHash)
        }

        let decryptedData: Data
        do {
            decryptedData = try self.crypto.decryptAndVerify(encryptedKeyknoxValue.meta + encryptedKeyknoxValue.value,
                                                             with: privateKey,
                                                             usingOneOf: publicKeys)
        }
        catch {
            throw KeyknoxCryptoError.decryptionFailed
        }

        return DecryptedKeyknoxValue(root: encryptedKeyknoxValue.root,
                                     path: encryptedKeyknoxValue.path,
                                     key: encryptedKeyknoxValue.key,
                                     owner: encryptedKeyknoxValue.owner,
                                     identities: encryptedKeyknoxValue.identities,
                                     meta: encryptedKeyknoxValue.meta,
                                     value: decryptedData,
                                     keyknoxHash: encryptedKeyknoxValue.keyknoxHash)
    }

    /// Encrypts data for Keyknox
    ///
    /// - Parameters:
    ///   - data: Data to encrypt
    ///   - privateKey: Private key to sign data. Should be of type VirgilPrivateKey
    ///   - publicKeys: Public keys to encrypt data. Should be of type VirgilPublicKey
    /// - Returns: Meta information and encrypted blob
    /// - Throws:
    ///   - `KeyknoxCryptoError.emptyPublicKeysList` is public keys list is empty
    ///   - `KeyknoxCryptoError.emptyData` if data if empty
    ///   - Rethrows from `RecipientCipher`, `Signer`
    open func encrypt(data: Data, privateKey: VirgilPrivateKey, publicKeys: [VirgilPublicKey]) throws -> (Data, Data) {
        guard !publicKeys.isEmpty else {
            throw KeyknoxCryptoError.emptyPublicKeysList
        }

        guard !data.isEmpty else {
            throw KeyknoxCryptoError.emptyData
        }

        let signature = try self.crypto.generateSignature(of: data, using: privateKey)

        let aesGcm = Aes256Gcm()
        let cipher = RecipientCipher()

        cipher.setEncryptionCipher(encryptionCipher: aesGcm)
        cipher.setRandom(random: self.crypto.rng)

        publicKeys.forEach {
            cipher.addKeyRecipient(recipientId: $0.identifier, publicKey: $0.key)
        }

        cipher.customParams().addData(key: VirgilCrypto.CustomParamKeySignature, value: signature)
        cipher.customParams().addData(key: VirgilCrypto.CustomParamKeySignerId, value: privateKey.identifier)

        try cipher.startEncryption()

        let meta = cipher.packMessageInfo()

        var encryptedData = try cipher.processEncryption(data: data)

        encryptedData += try cipher.finishEncryption()

        return (meta, encryptedData)
    }
}
