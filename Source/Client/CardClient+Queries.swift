//
//  CardClient+Queries.swift
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 9/20/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

import Foundation

// MARK: - Queries
extension CardClient: CardClientProtocol {
    /// HTTP header key for getCard response that marks outdated cards
    @objc public static let xVirgilIsSuperseededKey = "x-virgil-is-superseeded"
    /// HTTP header value for xVirgilIsSuperseededKey key for getCard response that marks outdated cards
    @objc public static let xVirgilIsSuperseededTrue = "true"

    /// Returns `GetCardResponse` with `RawSignedModel` of card from the Virgil Cards Service with given ID, if exists
    ///
    /// - Parameters:
    ///   - cardId: String with unique Virgil Card identifier
    ///   - token: String with `Access Token`
    /// - Returns: `GetCardResponse` if card found
    /// - Throws: CardClientError.constructingUrl, if url initialization failed
    ///           CardServiceError, if service returned correctly-formed error json
    ///           CardClientError.noBody, if response's body is empty
    ///           NSError with CardClient.serviceErrorDomain error domain,
    ///               http status code as error code, and description string if present in http body
    ///           Rethrows from ServiceRequest, HttpConnectionProtocol, JsonDecoder
    @objc open func getCard(withId cardId: String, token: String) throws -> GetCardResponse {
        guard let url = URL(string: "card/v5/\(cardId)", relativeTo: self.serviceUrl) else {
            throw CardClientError.constructingUrl
        }

        let request = try ServiceRequest(url: url, method: .get, accessToken: token)

        let response = try self.connection.send(request)

        let isOutdated: Bool
        if let xVirgilIsSuperseeded = response.response.allHeaderFields[CardClient.xVirgilIsSuperseededKey] as? String,
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
    /// - Parameters:
    ///   - model: Signed `RawSignedModel`
    ///   - token: String with `Access Token`
    /// - Returns: `RawSignedModel` of created card
    /// - Throws: CardClientError.constructingUrl, if url initialization failed
    ///           CardServiceError, if service returned correctly-formed error json
    ///           CardClientError.noBody, if response's body is empty
    ///           NSError with CardClient.serviceErrorDomain error domain,
    ///               http status code as error code, and description string if present in http body
    ///           Rethrows from ServiceRequest, HttpConnectionProtocol, JsonDecoder
    @objc open func publishCard(model: RawSignedModel, token: String) throws -> RawSignedModel {
        guard let url = URL(string: "card/v5", relativeTo: self.serviceUrl) else {
            throw CardClientError.constructingUrl
        }

        let request = try ServiceRequest(url: url, method: .post, accessToken: token, params: model)

        let response = try self.connection.send(request)

        return try self.processResponse(response)
    }

    /// Performs search of Virgil Cards using given identity on the Virgil Cards Service
    ///
    /// - Parameters:
    ///   - identity: Identity of cards to search
    ///   - token: String with `Access Token`
    /// - Returns: Array with `RawSignedModel`s of matched Virgil Cards
    /// - Throws: CardClientError.constructingUrl, if url initialization failed
    ///           CardServiceError, if service returned correctly-formed error json
    ///           CardClientError.noBody, if response's body is empty
    ///           NSError with CardClient.serviceErrorDomain error domain,
    ///               http status code as error code, and description string if present in http body
    ///           Rethrows from ServiceRequest, HttpConnectionProtocol, JsonDecoder
    @objc open func searchCards(identity: String, token: String) throws -> [RawSignedModel] {
        guard let url = URL(string: "card/v5/actions/search", relativeTo: self.serviceUrl) else {
            throw CardClientError.constructingUrl
        }

        let request = try ServiceRequest(url: url, method: .post, accessToken: token, params: ["identity": identity])

        let response = try self.connection.send(request)

        return try self.processResponse(response)
    }
}
