//
// Copyright (C) 2015-2019 Virgil Security Inc.
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

// MARK: - Queries
extension KeyknoxManager {
    open func pushValue(params: KeyknoxPushParams? = nil,
                        data: Data,
                        previousHash: Data?,
                        publicKeys: [VirgilPublicKey],
                        privateKey: VirgilPrivateKey) -> GenericOperation<DecryptedKeyknoxValue> {
        return CallbackOperation { _, completion in
            self.queue.async {
                do {
                    let encryptedData = try self.crypto.encrypt(data: data,
                                                                privateKey: privateKey,
                                                                publicKeys: publicKeys)
                    let keyknoxValue = try self.keyknoxClient.pushValue(params: params,
                                                                        meta: encryptedData.0,
                                                                        value: encryptedData.1,
                                                                        previousHash: previousHash)
                    let decryptedData = try self.crypto.decrypt(encryptedKeyknoxValue: keyknoxValue,
                                                                privateKey: privateKey,
                                                                publicKeys: publicKeys)

                    completion(decryptedData, nil)
                }
                catch {
                    completion(nil, error)
                }
            }
        }
    }

    open func pullValue(params: KeyknoxPullParams? = nil,
                        publicKeys: [VirgilPublicKey],
                        privateKey: VirgilPrivateKey) -> GenericOperation<DecryptedKeyknoxValue> {
        return CallbackOperation { _, completion in
            self.queue.async {
                do {
                    let keyknoxValue = try self.keyknoxClient.pullValue(params: params)
                    let decryptedData = try self.crypto.decrypt(encryptedKeyknoxValue: keyknoxValue,
                                                                privateKey: privateKey,
                                                                publicKeys: publicKeys)

                    completion(decryptedData, nil)
                }
                catch {
                    completion(nil, error)
                }
            }
        }
    }

    open func getKeys(params: KeyknoxGetKeysParams) -> GenericOperation<Set<String>> {
        return CallbackOperation { _, completion in
            self.queue.async {
                do {
                    let keys = try self.keyknoxClient.getKeys(params: params)

                    completion(keys, nil)
                }
                catch {
                    completion(nil, error)
                }
            }
        }
    }

    /// Resets Keyknox value (makes it empty). Also increments version
    ///
    /// - Returns: GenericOperation<Void>
    open func resetValue(params: KeyknoxResetParams? = nil) -> GenericOperation<DecryptedKeyknoxValue> {
        return CallbackOperation { _, completion in
            self.queue.async {
                do {
                    let resetValueResult = try self.keyknoxClient.resetValue(params: params)
                    completion(resetValueResult, nil)
                }
                catch {
                    completion(nil, error)
                }
            }
        }
    }

    /// Updates public keys for encryption and signature verification
    /// and private key for decryption and signature generation
    ///
    /// - Parameters:
    ///   - value: Current Keyknox value
    ///   - previousHash: Previous Keyknox value hash
    ///   - newPublicKeys: New public keys that will be used for encryption and signature verification
    ///   - newPrivateKey: New private key that will be used for decryption and signature generation
    /// - Returns: CallbackOperation<DecryptedKeyknoxValue>
    open func updateRecipients(params: KeyknoxPushParams? = nil,
                               value: Data,
                               previousHash: Data,
                               newPublicKeys: [VirgilPublicKey],
                               newPrivateKey: VirgilPrivateKey) -> GenericOperation<DecryptedKeyknoxValue> {
        return CallbackOperation { _, completion in
            self.queue.async {
                guard !value.isEmpty else {
                    completion(nil, KeyknoxManagerError.dataIsEmpty)
                    return
                }

                do {
                    let encryptedData = try self.crypto.encrypt(data: value,
                                                                privateKey: newPrivateKey,
                                                                publicKeys: newPublicKeys)
                    let keyknoxValue = try self.keyknoxClient.pushValue(params: params,
                                                                        meta: encryptedData.0,
                                                                        value: encryptedData.1,
                                                                        previousHash: previousHash)
                    let decryptedData = try self.crypto.decrypt(encryptedKeyknoxValue: keyknoxValue,
                                                                privateKey: newPrivateKey,
                                                                publicKeys: newPublicKeys)

                    completion(decryptedData, nil)
                }
                catch {
                    completion(nil, error)
                }

            }
        }
    }
}
