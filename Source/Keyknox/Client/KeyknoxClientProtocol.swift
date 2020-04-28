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

/// Protocol for KeyknoxClient
///
/// See: KeyknoxClient for default implementation
@objc(VSSKeyknoxClientProtocol) public protocol KeyknoxClientProtocol: class {
    /// Push value to Keyknox service
    ///
    /// - Parameters:
    ///   - params: params
    ///   - meta: meta data
    ///   - value: encrypted blob
    ///   - previousHash: hash of previous blob
    /// - Returns: EncryptedKeyknoxValue
    /// - Throws: Depends on implementation
    @objc func pushValue(params: KeyknoxPushParams?,
                         meta: Data,
                         value: Data,
                         previousHash: Data?) throws -> EncryptedKeyknoxValue

    /// Pulls values from Keyknox service
    ///
    /// - Parameter params: Pull params
    /// - Returns: EncryptedKeyknoxValue
    /// - Throws: Depends on implementation
    @objc func pullValue(params: KeyknoxPullParams?) throws -> EncryptedKeyknoxValue

    /// Get keys for given root
    ///
    /// - Parameter params: Get keys params
    /// - Returns: Array of keys
    /// - Throws: Depends on implementation
    @objc func getKeys(params: KeyknoxGetKeysParams) throws -> Set<String>

    /// Resets Keyknox value (makes it empty)
    ///
    /// - Parameter params: Reset params
    /// - Returns: DecryptedKeyknoxValue
    /// - Throws: Depends on implementation
    @objc func resetValue(params: KeyknoxResetParams?) throws -> DecryptedKeyknoxValue

    /// Deletes recipient
    ///
    /// - Parameter params: Delete recipient params
    /// - Returns: DecryptedKeyknoxValue
    /// - Throws: Depends on implementation
    @objc func deleteRecipient(params: KeyknoxDeleteRecipientParams) throws -> DecryptedKeyknoxValue
}
