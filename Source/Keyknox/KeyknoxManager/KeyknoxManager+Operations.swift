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

extension KeyknoxManager {
    internal func pullValueOperation() throws -> EncryptedKeyknoxValue {
        return try self.keyknoxClient.pullValue()
    }

    internal func pushValueOperation(data: (Data, Data), previousHash: Data?) throws -> EncryptedKeyknoxValue {
        let response = try self.keyknoxClient.pushValue(meta: data.0,
                                                        value: data.1,
                                                        previousHash: previousHash)

        guard response.value == data.1 && response.meta == data.0 else {
            throw KeyknoxManagerError.serverRespondedWithTamperedValue
        }

        return response
    }

    internal func resetValueOperation() throws -> DecryptedKeyknoxValue {
        let response = try self.keyknoxClient.resetValue()

        guard response.value.isEmpty && response.meta.isEmpty else {
            throw KeyknoxManagerError.serverRespondedWithTamperedValue
        }
        
        return response
    }

    internal func decryptOperation(keyknoxData: EncryptedKeyknoxValue) throws -> DecryptedKeyknoxValue {
        return try self.crypto.decrypt(encryptedKeyknoxValue: keyknoxData,
                                       privateKey: self.privateKey,
                                       publicKeys: self.publicKeys)
    }

    internal func encryptOperation(data: Data,
                                   newPublicKeys: [VirgilPublicKey]? = nil,
                                   newPrivateKey: VirgilPrivateKey? = nil) throws -> (Data, Data) {
        if let newPublicKeys = newPublicKeys {
            guard !newPublicKeys.isEmpty else {
                throw KeyknoxManagerError.noPublicKeys
            }
            self.publicKeys = newPublicKeys
        }
        if let newPrivateKey = newPrivateKey {
            self.privateKey = newPrivateKey
        }

        return try self.crypto.encrypt(data: data,
                                       privateKey: self.privateKey,
                                       publicKeys: self.publicKeys)
    }
}
