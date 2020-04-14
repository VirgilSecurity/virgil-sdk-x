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
extension CardClient: CardClientProtocol {
    /// HTTP header key for getCard response that marks outdated cards
    @objc public static let xVirgilIsSuperseededKey = "x-virgil-is-superseeded"
    /// HTTP header value for xVirgilIsSuperseededKey key for getCard response that marks outdated cards
    @objc public static let xVirgilIsSuperseededTrue = "true"

    private func createRetry() -> RetryProtocol {
        return ExpBackoffRetry(config: self.retryConfig)
    }

    /// Returns `GetCardResponse` with `RawSignedModel` of card from the Virgil Cards Service with given ID, if exists
    ///
    /// - Parameter cardId: String with unique Virgil Card identifier
    /// - Returns: `GetCardResponse` if card found
    /// - Throws:
    ///   - `CardClientError.constructingUrl`, if url initialization failed
    ///   - Rethrows from `ServiceRequest`
    ///   - Rethrows `ServiceError` or `NSError` from `BaseClient`
    @objc open func getCard(withId cardId: String) throws -> GetCardResponse {
        guard let url = URL(string: "card/v5/\(cardId)", relativeTo: self.serviceUrl) else {
            throw CardClientError.constructingUrl
        }

        let tokenContext = TokenContext(service: "cards", operation: "get", forceReload: false)

        let request = try ServiceRequest(url: url, method: .get)

        let response = try self.sendWithRetry(request,
                                              retry: self.createRetry(),
                                              tokenContext: tokenContext)
            .startSync()
            .get()

        let isOutdated: Bool
        // Swift dictionaries doesn't support case-insensitive keys, NSDictionary does
        let allHeaders = (response.response.allHeaderFields as NSDictionary)
        if let xVirgilIsSuperseeded = allHeaders[CardClient.xVirgilIsSuperseededKey] as? String,
            xVirgilIsSuperseeded == CardClient.xVirgilIsSuperseededTrue {
                isOutdated = true
        }
        else {
            isOutdated = false
        }

        return GetCardResponse(rawCard: try self.processResponse(response), isOutdated: isOutdated)
    }

    /// Creates Virgil Card instance on the Virgil Cards Service
    /// Also makes the Card accessible for search/get queries from other users
    /// `RawSignedModel` should contain appropriate signatures
    ///
    /// - Parameter model: Signed `RawSignedModel`
    /// - Returns: `RawSignedModel` of created card
    /// - Throws:
    ///   - `CardClientError.constructingUrl`, if url initialization failed
    ///   - Rethrows from `ServiceRequest`
    ///   - Rethrows `ServiceError` or `NSError` from `BaseClient`
    @objc open func publishCard(model: RawSignedModel) throws -> RawSignedModel {
        guard let url = URL(string: "card/v5", relativeTo: self.serviceUrl) else {
            throw CardClientError.constructingUrl
        }

        let tokenContext = TokenContext(service: "cards", operation: "publish", forceReload: false)

        let request = try ServiceRequest(url: url, method: .post, params: model)

        let response = try self.sendWithRetry(request,
                                              retry: self.createRetry(),
                                              tokenContext: tokenContext)
            .startSync()
            .get()

        return try self.processResponse(response)
    }

    /// Performs search of Virgil Cards using given identities on the Virgil Cards Service
    ///
    /// - Parameter identities: Identities of cards to search
    /// - Returns: Array with `RawSignedModel`s of matched Virgil Cards
    /// - Throws:
    ///   - CardClientError.constructingUrl, if url initialization failed
    ///   - ServiceError, if service returned correctly-formed error json
    ///   - NSError with CardClient.serviceErrorDomain error domain,
    ///     http status code as error code, and description string if present in http body
    ///   - Rethrows from `ServiceRequest`, `HttpConnectionProtocol`, `JsonDecoder`, `BaseClient`
    @objc public func searchCards(identities: [String]) throws -> [RawSignedModel] {
        guard let url = URL(string: "card/v5/actions/search", relativeTo: self.serviceUrl) else {
            throw CardClientError.constructingUrl
        }

        let tokenContext = TokenContext(service: "cards", operation: "search", forceReload: false)

        let request = try ServiceRequest(url: url,
                                         method: .post,
                                         params: ["identities": identities])

        let response = try self.sendWithRetry(request,
                                              retry: self.createRetry(),
                                              tokenContext: tokenContext)
            .startSync()
            .get()

        return try self.processResponse(response)
    }

    /// Returns list of cards that were replaced with newer ones
    ///
    /// - Parameter cardIds: card ids to check
    /// - Returns: List of old card ids
    /// - Throws:
    ///   - CardClientError.constructingUrl, if url initialization failed
    ///   - ServiceError, if service returned correctly-formed error json
    ///   - NSError with CardClient.serviceErrorDomain error domain,
    ///     http status code as error code, and description string if present in http body
    ///   - Rethrows from `ServiceRequest`, `HttpConnectionProtocol`, `JsonDecoder`, `BaseClient`
    @objc public func getOutdated(cardIds: [String]) throws -> [String] {
        guard let url = URL(string: "card/v5/actions/outdated", relativeTo: self.serviceUrl) else {
            throw CardClientError.constructingUrl
        }

        let tokenContext = TokenContext(service: "cards", operation: "get-outdated", forceReload: false)

        let request = try ServiceRequest(url: url,
                                         method: .post,
                                         params: ["card_ids": cardIds])

        let response = try self.sendWithRetry(request,
                                              retry: self.createRetry(),
                                              tokenContext: tokenContext)
            .startSync()
            .get()

        return try self.processResponse(response)
    }

    /// Revokes card. Revoked card gets isOutdated flag to be set to true.
    /// Also, such cards could be obtained using get query, but will be absent in search query result.
    ///
    /// - Parameter cardId: identifier of card to revoke
    /// - Throws:
    ///   - CardClientError.constructingUrl, if url initialization failed
    ///   - ServiceError, if service returned correctly-formed error json
    ///   - NSError with CardClient.serviceErrorDomain error domain,
    ///     http status code as error code, and description string if present in http body
    ///   - Rethrows from `ServiceRequest`, `HttpConnectionProtocol`, `JsonDecoder`, `BaseClient`
    @objc public func revokeCard(withId cardId: String) throws {
        guard let url = URL(string: "card/v5/actions/revoke/\(cardId)", relativeTo: self.serviceUrl) else {
            throw CardClientError.constructingUrl
        }

        let tokenContext = TokenContext(service: "cards", operation: "revoke", forceReload: false)

        let request = try ServiceRequest(url: url,
                                         method: .post)

        let response = try self.sendWithRetry(request,
                                              retry: self.createRetry(),
                                              tokenContext: tokenContext)
            .startSync()
            .get()

        try self.validateResponse(response)
    }
}
