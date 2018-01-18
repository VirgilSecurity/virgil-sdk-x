//
//  CardClient+Queries.swift
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 9/20/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

import Foundation

extension CardClient {
    @objc public func getCard(withId cardId: String, token: String) throws -> RawSignedModel {
        guard let url = URL(string: "card/\(cardId)", relativeTo: self.baseUrl) else {
            throw CardClientError.constructingUrl
        }
        
        let request = try ServiceRequest(url: url, method: .get, apiToken: token)
        
        let response = try self.connection.send(request)
        
        return try self.processResponse(response)
    }
    
    @objc public func publishCard(request: RawSignedModel, token: String) throws -> RawSignedModel {
        guard let url = URL(string: "card", relativeTo: self.baseUrl) else {
            throw CardClientError.constructingUrl
        }
        
        let request = try ServiceRequest(url: url, method: .post, apiToken: token, bodyJson: request.asJson())
        
        let response = try self.connection.send(request)
        
        return try self.processResponse(response)
    }
    
    // FIXME
    @objc public func searchCards(identity: String, token: String) throws -> [RawSignedModel] {
        guard let url = URL(string: "card/actions/search", relativeTo: self.baseUrl) else {
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
        
        guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [[AnyHashable : Any]] else {
            throw CardClientError.invalidJson
        }
        
        var result: [RawSignedModel] = []
        for item in json {
            guard let responseModel = RawSignedModel(dict: item) else {
                throw CardClientError.invalidResponseModel
            }
            result.append(responseModel)
        }
        
        return result
    }
}
