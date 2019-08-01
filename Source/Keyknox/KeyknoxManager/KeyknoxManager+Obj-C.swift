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

// MARK: - Obj-C extension
extension KeyknoxManager {
    @objc open func pushValue(identities: [String],
                              root1: String,
                              root2: String,
                              key: String,
                              data: Data,
                              previousHash: Data?,
                              publicKeys: [VirgilPublicKey],
                              privateKey: VirgilPrivateKey,
                              completion: @escaping (DecryptedKeyknoxValue?, Error?) -> Void) {
        self.pushValue(identities: identities,
                       root1: root1,
                       root2: root2,
                       key: key,
                       data: data,
                       previousHash: previousHash,
                       publicKeys: publicKeys,
                       privateKey: privateKey).start(completion: completion)
    }

    @objc open func pullValue(identity: String?,
                              root1: String,
                              root2: String,
                              key: String,
                              publicKeys: [VirgilPublicKey],
                              privateKey: VirgilPrivateKey,
                              completion: @escaping (DecryptedKeyknoxValue?, Error?) -> Void) {
        self.pullValue(identity: identity,
                       root1: root1,
                       root2: root2,
                       key: key,
                       publicKeys: publicKeys,
                       privateKey: privateKey).start(completion: completion)
    }

    @objc open func getKeys(identity: String?,
                            root1: String?,
                            root2: String?,
                            completion: @escaping (Set<String>?, Error?) -> Void) {
        self.getKeys(identity: identity, root1: root1, root2: root2).start(completion: completion)
    }

    @objc open func resetValue(root1: String?,
                               root2: String?,
                               key: String?,
                               completion: @escaping(DecryptedKeyknoxValue?, Error?) -> Void) {
        self.resetValue(root1: root1, root2: root2, key: key).start(completion: completion)
    }

    @objc open func updateRecipients(identities: [String],
                                     root1: String,
                                     root2: String,
                                     key: String,
                                     oldPublicKeys: [VirgilPublicKey],
                                     oldPrivateKey: VirgilPrivateKey,
                                     newPublicKeys: [VirgilPublicKey]? = nil,
                                     newPrivateKey: VirgilPrivateKey? = nil,
                                     completion: @escaping (DecryptedKeyknoxValue?, Error?) -> Void) {
        self.updateRecipients(identities: identities,
                              root1: root1,
                              root2: root2,
                              key: key,
                              oldPublicKeys: oldPublicKeys,
                              oldPrivateKey: oldPrivateKey,
                              newPublicKeys: newPublicKeys,
                              newPrivateKey: newPrivateKey).start(completion: completion)
    }

    @objc open func updateRecipients(identities: [String],
                                     root1: String,
                                     root2: String,
                                     key: String,
                                     value: Data,
                                     previousHash: Data,
                                     newPublicKeys: [VirgilPublicKey],
                                     newPrivateKey: VirgilPrivateKey,
                                     completion: @escaping (DecryptedKeyknoxValue?, Error?) -> Void) {
        self.updateRecipients(identities: identities,
                              root1: root1,
                              root2: root2,
                              key: key,
                              value: value,
                              previousHash: previousHash,
                              newPublicKeys: newPublicKeys,
                              newPrivateKey: newPrivateKey).start(completion: completion)
    }
}
