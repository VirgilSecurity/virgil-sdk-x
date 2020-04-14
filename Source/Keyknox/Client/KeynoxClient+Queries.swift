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

// MARK: - Queries
extension KeyknoxClient: KeyknoxClientProtocol {
    /// Header key for blob hash
    @objc public static let virgilKeyknoxHashKey = "Virgil-Keyknox-Hash"

    /// Header key for previous blob hash
    @objc public static let virgilKeyknoxPreviousHashKey = "Virgil-Keyknox-Previous-Hash"

    /// Default root value
    @objc public static let keyStorageRoot = "DEFAULT_ROOT"

    /// Default path value
    @objc public static let keyStoragePath = "DEFAULT_PATH"

    /// Default key value
    @objc public static let keyStorageKey = "DEFAULT_KEY"

    private func createRetry() -> RetryProtocol {
        return ExpBackoffRetry(config: self.retryConfig)
    }

    // TODO: Remove this workaround for old API support
    private func extractIdentity(operation: GenericOperation<Response>) throws -> String {
        guard let networkOperation = operation as? NetworkRetryOperation,
            let token = networkOperation.token else {
                fatalError("Keyknox operations typing failed")
        }

        return token.identity()
    }

    /// Push value to Keyknox service
    ///
    /// - Parameters:
    ///   - params: params
    ///   - meta: meta data
    ///   - value: encrypted blob
    ///   - previousHash: hash of previous blob
    /// - Returns: EncryptedKeyknoxValue
    /// - Throws:
    ///   - KeyknoxClientError.emptyIdentities, if identities are empty
    ///   - KeyknoxClientError.constructingUrl, if url initialization failed
    ///   - KeyknoxClientError.invalidOptions, if internal options error occured
    ///   - ServiceError, if service returned correctly-formed error json
    ///   - NSError with KeyknoxClient.serviceErrorDomain error domain,
    ///     http status code as error code, and description string if present in http body
    ///   - Rethrows from `ServiceRequest`, `HttpConnectionProtocol`, `JsonDecoder`, `BaseClient`
    @objc public func pushValue(params: KeyknoxPushParams? = nil,
                                meta: Data,
                                value: Data,
                                previousHash: Data?) throws -> EncryptedKeyknoxValue {
        let headers: [String: String]
        if let previousHash = previousHash {
            headers = [KeyknoxClient.virgilKeyknoxPreviousHashKey: previousHash.base64EncodedString()]
        }
        else {
            headers = [:]
        }

        let request: ServiceRequest

        var queryParams: [String: Encodable] = [
            "meta": meta.base64EncodedString(),
            "value": value.base64EncodedString()
        ]

        if let params = params {
            guard !params.identities.isEmpty else {
                throw KeyknoxClientError.emptyIdentities
            }

            guard let url = URL(string: "keyknox/v2/push", relativeTo: self.serviceUrl) else {
                throw KeyknoxClientError.constructingUrl
            }

            try queryParams.merge([
                "root": params.root,
                "path": params.path,
                "key": params.key,
                "identities": params.identities
            ]) { _, _ -> Encodable in
                    throw KeyknoxClientError.invalidOptions
            }

            request = try ServiceRequest(url: url, method: .post, params: queryParams, headers: headers)
        }
        else {
            guard let url = URL(string: "keyknox/v1", relativeTo: self.serviceUrl) else {
                throw KeyknoxClientError.constructingUrl
            }

            request = try ServiceRequest(url: url, method: .put, params: queryParams, headers: headers)
        }

        let tokenContext = TokenContext(service: "keyknox", operation: "put")

        let networkOperation = try self.sendWithRetry(request,
                                                      retry: self.createRetry(),
                                                      tokenContext: tokenContext)

        let response = try networkOperation.startSync().get()

        let keyknoxValue: EncryptedKeyknoxValue

        if params == nil {
            let keyknoxData: KeyknoxData = try self.processResponse(response)
            let keyknoxHash = try self.extractKeyknoxHash(response: response)

            let identity = try self.extractIdentity(operation: networkOperation)

            keyknoxValue = EncryptedKeyknoxValue(keyknoxData: keyknoxData, keyknoxHash: keyknoxHash, identity: identity)
        }
        else {
            let keyknoxData: KeyknoxDataV2 = try self.processResponse(response)
            let keyknoxHash = try self.extractKeyknoxHash(response: response)
            keyknoxValue = EncryptedKeyknoxValue(keyknoxData: keyknoxData, keyknoxHash: keyknoxHash)
        }

        return keyknoxValue
    }

    /// Pulls values from Keyknox service
    ///
    /// - Parameter params: Pull params
    /// - Returns: EncryptedKeyknoxValue
    /// - Throws:
    ///   - KeyknoxClientError.constructingUrl, if url initialization failed
    ///   - ServiceError, if service returned correctly-formed error json
    ///   - NSError with KeyknoxClient.serviceErrorDomain error domain,
    ///     http status code as error code, and description string if present in http body
    ///   - Rethrows from `ServiceRequest`, `HttpConnectionProtocol`, `JsonDecoder`, `BaseClient`
    @objc public func pullValue(params: KeyknoxPullParams? = nil) throws -> EncryptedKeyknoxValue {
        let request: ServiceRequest

        if let params = params {
            guard let url = URL(string: "keyknox/v2/pull", relativeTo: self.serviceUrl) else {
                throw KeyknoxClientError.constructingUrl
            }

            let queryParams = [
                "root": params.root,
                "path": params.path,
                "key": params.key,
                "identity": params.identity
            ]

            request = try ServiceRequest(url: url, method: .post, params: queryParams)
        }
        else {
            guard let url = URL(string: "keyknox/v1", relativeTo: self.serviceUrl) else {
                throw KeyknoxClientError.constructingUrl
            }

            request = try ServiceRequest(url: url, method: .get)
        }

        let tokenContext = TokenContext(service: "keyknox", operation: "get")

        let networkOperation = try self.sendWithRetry(request,
                                                      retry: self.createRetry(),
                                                      tokenContext: tokenContext)

        let response = try networkOperation.startSync().get()

        let keyknoxValue: EncryptedKeyknoxValue

        if params == nil {
            let keyknoxData: KeyknoxData = try self.processResponse(response)
            let keyknoxHash = try self.extractKeyknoxHash(response: response)
            let identity = try self.extractIdentity(operation: networkOperation)

            keyknoxValue = EncryptedKeyknoxValue(keyknoxData: keyknoxData, keyknoxHash: keyknoxHash, identity: identity)
        }
        else {
            let keyknoxData: KeyknoxDataV2 = try self.processResponse(response)
            let keyknoxHash = try self.extractKeyknoxHash(response: response)
            keyknoxValue = EncryptedKeyknoxValue(keyknoxData: keyknoxData, keyknoxHash: keyknoxHash)
        }

        return keyknoxValue
    }

    /// Get keys for given root
    ///
    /// - Parameter params: Get keys params
    /// - Returns: Array of keys
    /// - Throws:
    ///   - KeyknoxClientError.constructingUrl, if url initialization failed
    ///   - ServiceError, if service returned correctly-formed error json
    ///   - NSError with KeyknoxClient.serviceErrorDomain error domain,
    ///     http status code as error code, and description string if present in http body
    ///   - Rethrows from `ServiceRequest`, `HttpConnectionProtocol`, `JsonDecoder`, `BaseClient`
    @objc public func getKeys(params: KeyknoxGetKeysParams) throws -> Set<String> {
        guard let url = URL(string: "keyknox/v2/keys", relativeTo: self.serviceUrl) else {
            throw KeyknoxClientError.constructingUrl
        }

        var queryParams: [String: String] = [:]

        if let identity = params.identity {
            queryParams["identity"] = identity
        }

        if let root = params.root {
            queryParams["root"] = root
        }

        if let path = params.path {
            queryParams["path"] = path
        }

        let request = try ServiceRequest(url: url, method: .post, params: queryParams)

        let tokenContext = TokenContext(service: "keyknox", operation: "get")

        let response = try self.sendWithRetry(request,
                                              retry: self.createRetry(),
                                              tokenContext: tokenContext)
            .startSync()
            .get()

        let keys: [String] = try self.processResponse(response)

        return Set(keys)
    }

    /// Resets Keyknox value (makes it empty)
    ///
    /// - Parameter params: Reset params
    /// - Returns: DecryptedKeyknoxValue
    /// - Throws:
    ///   - KeyknoxClientError.constructingUrl, if url initialization failed
    ///   - ServiceError, if service returned correctly-formed error json
    ///   - NSError with KeyknoxClient.serviceErrorDomain error domain,
    ///     http status code as error code, and description string if present in http body
    ///   - Rethrows from `ServiceRequest`, `HttpConnectionProtocol`, `JsonDecoder`, `BaseClient`
    @objc open func resetValue(params: KeyknoxResetParams? = nil) throws -> DecryptedKeyknoxValue {
        let request: ServiceRequest

        if let params = params {
            guard let url = URL(string: "keyknox/v2/reset", relativeTo: self.serviceUrl) else {
                throw KeyknoxClientError.constructingUrl
            }

            var queryParams: [String: String] = [:]

            if let root = params.root {
                queryParams["root"] = root
            }

            if let path = params.path {
                queryParams["path"] = path
            }

            if let key = params.key {
                queryParams["key"] = key
            }

            request = try ServiceRequest(url: url, method: .post, params: queryParams)
        }
        else {
            guard let url = URL(string: "keyknox/v1/reset", relativeTo: self.serviceUrl) else {
                throw KeyknoxClientError.constructingUrl
            }

            request = try ServiceRequest(url: url, method: .post)
        }

        let tokenContext = TokenContext(service: "keyknox", operation: "delete")

        let networkOperation = try self.sendWithRetry(request,
                                                      retry: self.createRetry(),
                                                      tokenContext: tokenContext)

        let response = try networkOperation.startSync().get()

        let keyknoxValue: DecryptedKeyknoxValue

        if params == nil {
            let keyknoxData: KeyknoxData = try self.processResponse(response)
            let keyknoxHash = try self.extractKeyknoxHash(response: response)
            let identity = try self.extractIdentity(operation: networkOperation)

            keyknoxValue = DecryptedKeyknoxValue(keyknoxData: keyknoxData, keyknoxHash: keyknoxHash, identity: identity)
        }
        else {
            let keyknoxData: KeyknoxDataV2 = try self.processResponse(response)
            let keyknoxHash = try self.extractKeyknoxHash(response: response)
            keyknoxValue = DecryptedKeyknoxValue(keyknoxData: keyknoxData, keyknoxHash: keyknoxHash)
        }

        return keyknoxValue
    }

    /// Deletes recipient
    ///
    /// - Parameter params: Delete recipient params
    /// - Returns: DecryptedKeyknoxValue
    /// - Throws:
    ///   - KeyknoxClientError.constructingUrl, if url initialization failed
    ///   - ServiceError, if service returned correctly-formed error json
    ///   - NSError with KeyknoxClient.serviceErrorDomain error domain,
    ///     http status code as error code, and description string if present in http body
    ///   - Rethrows from `ServiceRequest`, `HttpConnectionProtocol`, `JsonDecoder`, `BaseClient`
    @objc open func deleteRecipient(params: KeyknoxDeleteRecipientParams) throws -> DecryptedKeyknoxValue {
        guard let url = URL(string: "keyknox/v2/reset", relativeTo: self.serviceUrl) else {
            throw KeyknoxClientError.constructingUrl
        }

        var queryParams = [
            "identity": params.identity,
            "root": params.root,
            "path": params.path
        ]

        if let key = params.key {
            queryParams["key"] = key
        }

        let request = try ServiceRequest(url: url, method: .post, params: queryParams)

        let tokenContext = TokenContext(service: "keyknox", operation: "delete")

        let networkOperation = try self.sendWithRetry(request,
                                                      retry: self.createRetry(),
                                                      tokenContext: tokenContext)

        let response = try networkOperation.startSync().get()

        let keyknoxData: KeyknoxDataV2 = try self.processResponse(response)

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
