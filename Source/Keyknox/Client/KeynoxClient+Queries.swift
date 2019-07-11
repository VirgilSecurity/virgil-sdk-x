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

// MARK: - Queries
extension KeyknoxClient: KeyknoxClientProtocol {
    
    /// Header key for blob hash
    @objc public static let virgilKeyknoxHashKey = "Virgil-Keyknox-Hash"

    /// Header key for previous blob hash
    @objc public static let virgilKeyknoxPreviousHashKey = "Virgil-Keyknox-Previous-Hash"

    private func createRetry() -> RetryProtocol {
        return ExpBackoffRetry(config: self.retryConfig)
    }

    public func pushValue(identities: [String],
                          root1: String,
                          root2: String,
                          key: String,
                          meta: Data,
                          value: Data,
                          previousHash: Data?,
                          overwrite: Bool) throws -> EncryptedKeyknoxValue {
        guard let url = URL(string: "keyknox/v1", relativeTo: self.serviceUrl) else {
            throw KeyknoxClientError.constructingUrl
        }

        let params = [
            "meta": meta.base64EncodedString(),
            "value": value.base64EncodedString()
        ]

        let headers: [String: String]
        if let previousHash = previousHash {
            headers = [KeyknoxClient.virgilKeyknoxPreviousHashKey: previousHash.base64EncodedString()]
        }
        else {
            headers = [:]
        }

        let request = try ServiceRequest(url: url, method: .put, params: params, headers: headers)

        let tokenContext = TokenContext(service: "keyknox", operation: "put", forceReload: false)

        let response = try self.sendWithRetry(request,
                                              retry: self.createRetry(),
                                              tokenContext: tokenContext)
            .startSync()
            .get()

        let keyknoxData: KeyknoxData = try self.processResponse(response)

        let keyknoxHash = try self.extractKeyknoxHash(response: response)

        return EncryptedKeyknoxValue(keyknoxData: keyknoxData, keyknoxHash: keyknoxHash)
    }
    
    public func pullValue(identity: String?, root1: String, root2: String, key: String) throws -> EncryptedKeyknoxValue {
        guard let url = URL(string: "keyknox/v1", relativeTo: self.serviceUrl) else {
            throw KeyknoxClientError.constructingUrl
        }

        let request = try ServiceRequest(url: url, method: .get)

        let tokenContext = TokenContext(service: "keyknox", operation: "get", forceReload: false)
        let response = try self.sendWithRetry(request,
                                              retry: self.createRetry(),
                                              tokenContext: tokenContext)
            .startSync()
            .get()

        let keyknoxData: KeyknoxData = try self.processResponse(response)

        let keyknoxHash = try self.extractKeyknoxHash(response: response)

        return EncryptedKeyknoxValue(keyknoxData: keyknoxData, keyknoxHash: keyknoxHash)
    }
    
    public func getKeys(identity: String?, root1: String?, root2: String?) throws -> [String] {
        throw NSError()
    }

    @objc open func resetValue(identities: [String],
                               root1: String?,
                               root2: String?,
                               key: String?) throws -> DecryptedKeyknoxValue {
        guard let url = URL(string: "keyknox/v1/reset", relativeTo: self.serviceUrl) else {
            throw KeyknoxClientError.constructingUrl
        }

        let request = try ServiceRequest(url: url, method: .post)
        let tokenContext = TokenContext(service: "keyknox", operation: "delete", forceReload: false)

        let response = try self.sendWithRetry(request,
                                              retry: self.createRetry(),
                                              tokenContext: tokenContext)
            .startSync()
            .get()

        let keyknoxData: KeyknoxData = try self.processResponse(response)

        let keyknoxHash = try self.extractKeyknoxHash(response: response)

        return DecryptedKeyknoxValue(keyknoxData: keyknoxData, keyknoxHash: keyknoxHash)
    }

    private func extractKeyknoxHash(response: Response) throws -> Data {
        let responseHeaders = response.response.allHeaderFields as NSDictionary

        guard let keyknoxHashStr = responseHeaders[KeyknoxClient.virgilKeyknoxHashKey] as? String,
            let keyknoxHash = Data(base64Encoded: keyknoxHashStr) else {
                throw KeyknoxClientError.invalidPreviousHashHeader
        }

        return keyknoxHash
    }
}
