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

/// Value stored on Keyknox service
@objc(VSSKeyknoxValue) public class KeyknoxValue: NSObject {
    @objc public let root: String
    @objc public let path: String
    @objc public let key: String
    @objc public let owner: String
    @objc public let identities: [String]

    /// Meta info
    @objc public let meta: Data

    /// Value
    @objc public let value: Data

    /// Keyknox hash
    @objc public let keyknoxHash: Data

    internal convenience init(keyknoxData: KeyknoxDataV2, keyknoxHash: Data) {
        self.init(root: keyknoxData.root,
                  path: keyknoxData.path,
                  key: keyknoxData.key,
                  owner: keyknoxData.owner,
                  identities: keyknoxData.identities,
                  meta: keyknoxData.meta,
                  value: keyknoxData.value,
                  keyknoxHash: keyknoxHash)
    }

    internal convenience init(keyknoxData: KeyknoxData, keyknoxHash: Data, identity: String) {
        self.init(root: KeyknoxClient.keyStorageRoot,
                  path: KeyknoxClient.keyStoragePath,
                  key: KeyknoxClient.keyStorageKey,
                  owner: identity,
                  identities: [identity],
                  meta: keyknoxData.meta,
                  value: keyknoxData.value,
                  keyknoxHash: keyknoxHash)
    }

    internal init(root: String,
                  path: String,
                  key: String,
                  owner: String,
                  identities: [String],
                  meta: Data,
                  value: Data,
                  keyknoxHash: Data) {
        self.root = root
        self.path = path
        self.key = key
        self.owner = owner
        self.identities = identities
        self.meta = meta
        self.value = value
        self.keyknoxHash = keyknoxHash

        super.init()
    }
}

/// Represent encrypted Keyknox value
@objc(VSSEncryptedKeyknoxValue) public class EncryptedKeyknoxValue: KeyknoxValue { }

/// Represent decrypted Keyknox value
@objc(VSSDecryptedKeyknoxValue) public class DecryptedKeyknoxValue: KeyknoxValue { }
