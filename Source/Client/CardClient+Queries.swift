//
//  CardClient+Queries.swift
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 9/20/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

import Foundation

extension CardClient {
    @objc public func getCard(withId cardId: String, token: String) throws -> RawCard {
        guard let url = URL(string: "card/v5/\(cardId)", relativeTo: self.baseUrl) else {
            throw CardClientError.constructingUrl
        }
        
        let request = try ServiceRequest(url: url, method: .get, apiToken: token)
        
        let response = try self.connection.send(request)
        
        return try self.processResponse(response)
    }
    
    @objc public func publishCard(request: RawCard, token: String) throws -> RawCard {
        guard let url = URL(string: "card/v5", relativeTo: self.baseUrl) else {
            throw CardClientError.constructingUrl
        }
        
        let request = try ServiceRequest(url: url, method: .post, apiToken: token, bodyJson: request.serialize())
        
        let response = try self.connection.send(request)
        
        return try self.processResponse(response)
    }
    
    // SEARCH CARD
}
