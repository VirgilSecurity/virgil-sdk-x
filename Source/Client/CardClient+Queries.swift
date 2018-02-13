//
//  CardClient+Queries.swift
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 9/20/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

import Foundation

// MARK: - Queries
extension CardClient {
    /// Returns `RawSignedModel` of card from the Virgil Cards Service with given ID, if exists
    ///
    /// - Parameters:
    ///   - cardId: string with unique Virgil Card identifier
    ///   - token: string with `Access Token`
    /// - Returns: `GetCardResponse` if card found
    /// - Throws: corresponding error
    @objc open func getCard(withId cardId: String, token: String) throws -> GetCardResponse {
        guard let url = URL(string: "card/v5/\(cardId)", relativeTo: self.serviceUrl) else {
            throw CardClientError.constructingUrl
        }

        let request = try ServiceRequest(url: url, method: .get, apiToken: token)

        let response = try self.connection.send(request)

        let isOutdated = response.statusCode == 403 ? true : false

        return GetCardResponse(rawCard: try self.processResponse(response), isOutdated: isOutdated)
    }

    /// Creates Virgil Card instance on the Virgil Cards Service and associates it with unique identifier
    /// Also makes the Card accessible for search/get queries from other users
    /// `RawSignedModel` should be at least selfSigned
    ///
    /// - Parameters:
    ///   - model: self signed `RawSignedModel`
    ///   - token: string with `Access Token`
    /// - Returns: `RawSignedModel` of created card
    /// - Throws: corresponding error
    @objc open func publishCard(model: RawSignedModel, token: String) throws -> RawSignedModel {
        guard let url = URL(string: "card/v5", relativeTo: self.serviceUrl) else {
            throw CardClientError.constructingUrl
        }

        let request = try ServiceRequest(url: url, method: .post, apiToken: token, bodyJson: model.exportAsJson())

        let response = try self.connection.send(request)

        return try self.processResponse(response)
    }

    /// Performs search of Virgil Cards using identity on the Virgil Cards Service
    ///
    /// - Parameters:
    ///   - identity: identity of cards to search
    ///   - token: string with `Access Token`
    /// - Returns: array with RawSignedModels of matched Virgil Cards
    /// - Throws: corresponding error
    @objc open func searchCards(identity: String, token: String) throws -> [RawSignedModel] {
        guard let url = URL(string: "card/v5/actions/search", relativeTo: self.serviceUrl) else {
            throw CardClientError.constructingUrl
        }

        let request = try ServiceRequest(url: url, method: .post, apiToken: token, bodyJson: ["identity": identity])

        let response = try self.connection.send(request)

        guard response.statusCode == 200 else {
            throw self.handleError(statusCode: response.statusCode, body: response.body)
        }

        guard let data = response.body else {
            throw CardClientError.noBody
        }

        guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [[AnyHashable: Any]] else {
            throw CardClientError.invalidJson
        }

        var result: [RawSignedModel] = []
        for item in json {
            let data = try JSONSerialization.data(withJSONObject: item, options: [])
            let responseModel = try JSONDecoder().decode(RawSignedModel.self, from: data)

            result.append(responseModel)
        }

        return result
    }
}
