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

/// Options for managing ProtectedKey
@objc(VSSProtectedKeyOptions) public class ProtectedKeyOptions: NSObject {
    /// Access time during which key is cached in RAM. If nil, key won't be cleaned from RAM using timer. Default - nil
    public var accessTime: TimeInterval?

    /// KeychainStorage
    @objc public var keychainStorage: KeychainStorage!

#if os(iOS)
    @objc public var biometricallyProtected: Bool = false

    /// Cleans private key from RAM on background. Default - false
    @objc public var cleanOnEnterBackground: Bool = false

    /// Requests private key on entering foreground. Default - false
    @objc public var requestOnEnterForeground: Bool = false

    /// Error callback function type
    public typealias ErrorCallback = (Error) -> Void

    /// Error callback for errors during entering foreground. Default - nil
    public var enterForegroundErrorCallback: ErrorCallback? = nil

#endif

    @objc public static func makeOptions() throws -> ProtectedKeyOptions {
        let params = try KeychainStorageParams.makeKeychainStorageParams()
        let keychainStorage = KeychainStorage(storageParams: params)

        return ProtectedKeyOptions(keychainStorage: keychainStorage)
    }

    @objc public init(keychainStorage: KeychainStorage) {
        self.keychainStorage = keychainStorage
    }
}
