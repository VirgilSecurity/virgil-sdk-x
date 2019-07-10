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
    /// Signs then encrypts and pushed value to Keyknox service
    ///
    /// - Parameters:
    ///   - value: value to push
    ///   - previousHash: previous value hash
    /// - Returns: CallbackOperation<DecryptedKeyknoxValue>
    open func pushValue(_ value: Data, previousHash: Data?) -> GenericOperation<DecryptedKeyknoxValue> {
        return CallbackOperation { _, completion in
            self.queue.async {
                do {
                    let encryptResult = try self.encryptOperation(data: value)
                    let pushValueResult = try self.pushValueOperation(data: encryptResult, previousHash: previousHash)
                    let decryptResult = try self.decryptOperation(keyknoxData: pushValueResult)

                    completion(decryptResult, nil)
                }
                catch {
                    completion(nil, error)
                }
            }
        }
    }

    /// Pull value, decrypt then verify signature
    ///
    /// - Returns: CallbackOperation<DecryptedKeyknoxValue>
    open func pullValue() -> GenericOperation<DecryptedKeyknoxValue> {
        return CallbackOperation { _, completion in
            self.queue.async {
                do {
                    let pullValueResult = try self.pullValueOperation()
                    let decryptResult = try self.decryptOperation(keyknoxData: pullValueResult)

                    completion(decryptResult, nil)
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
    open func resetValue() -> GenericOperation<DecryptedKeyknoxValue> {
        return CallbackOperation { _, completion in
            self.queue.async {
                do {
                    let resetValueResult = try self.resetValueOperation()

                    completion(resetValueResult, nil)
                }
                catch {
                    completion(nil, error)
                }
            }
        }
    }

    /// Updates public keys for ecnryption and signature verification
    /// and private key for decryption and signature generation
    ///
    /// - Parameters:
    ///   - newPublicKeys: New public keys that will be used for encryption and signature verification
    ///   - newPrivateKey: New private key that will be used for decryption and signature generation
    /// - Returns: CallbackOperation<DecryptedKeyknoxValue>
    open func updateRecipients(newPublicKeys: [VirgilPublicKey]? = nil,
                               newPrivateKey: VirgilPrivateKey? = nil) -> GenericOperation<DecryptedKeyknoxValue> {
        return CallbackOperation { _, completion in
            self.queue.async {
                guard (newPublicKeys != nil && !(newPublicKeys?.isEmpty ?? true))
                    || newPrivateKey != nil else {
                        completion(nil, KeyknoxManagerError.keysShouldBeUpdated)
                        return
                }

                do {
                    let pullValueResult = try self.pullValueOperation()
                    let decryptResult = try self.decryptOperation(keyknoxData: pullValueResult)

                    guard !decryptResult.value.isEmpty else {
                        completion(decryptResult, nil)
                        return
                    }

                    let encryptResult = try self.encryptOperation(data: decryptResult.value,
                                                                  newPublicKeys: newPublicKeys,
                                                                  newPrivateKey: newPrivateKey)

                    let pushValueResult = try self.pushValueOperation(data: encryptResult,
                                                                      previousHash: pullValueResult.keyknoxHash)
                    let decryptResult2 = try self.decryptOperation(keyknoxData: pushValueResult)

                    completion(decryptResult2, nil)
                }
                catch {
                    completion(nil, error)
                }
            }
        }
    }

    /// Updates public keys for ecnryption and signature verification
    /// and private key for decryption and signature generation
    ///
    /// - Parameters:
    ///   - value: Current Keyknox value
    ///   - previousHash: Previous Keyknox value hash
    ///   - newPublicKeys: New public keys that will be used for encryption and signature verification
    ///   - newPrivateKey: New private key that will be used for decryption and signature generation
    /// - Returns: CallbackOperation<DecryptedKeyknoxValue>
    open func updateRecipients(value: Data, previousHash: Data,
                               newPublicKeys: [VirgilPublicKey]? = nil,
                               newPrivateKey: VirgilPrivateKey? = nil) -> GenericOperation<DecryptedKeyknoxValue> {
        return CallbackOperation { _, completion in
            self.queue.async {
                guard !value.isEmpty else {
                    completion(nil, KeyknoxManagerError.dataIsEmpty)
                    return
                }

                do {
                    let encryptResult = try self.encryptOperation(data: value,
                                                                  newPublicKeys: newPublicKeys,
                                                                  newPrivateKey: newPrivateKey)
                    let pushValueResult = try self.pushValueOperation(data: encryptResult, previousHash: previousHash)
                    let decryptResult = try self.decryptOperation(keyknoxData: pushValueResult)

                    completion(decryptResult, nil)
                }
                catch {
                    completion(nil, error)
                }

            }
        }
    }
}
