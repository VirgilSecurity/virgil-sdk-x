//
//  CardClient+Queries.swift
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 9/20/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

import Foundation

extension CardClient {
    public func getCard(withId cardId: String) throws -> RawCard {
        guard let url = URL(string: "card/\(cardId)", relativeTo: self.baseUrl) else {
            throw CardClientError.constructingUrl
        }
        
        let request = try ServiceRequest(url: url, method: .get, apiToken: self.apiToken)
        
        let response = try self.connection.send(request)
        
        return try self.processResponse(response)
    }
    
    public func publishCard(request: RawCard) throws -> RawCard {
        guard let url = URL(string: "card", relativeTo: self.baseUrl) else {
            throw CardClientError.constructingUrl
        }
        
        let request = try ServiceRequest(url: url, method: .post, apiToken: self.apiToken, bodyJson: request.serialize())
        
        let response = try self.connection.send(request)
        
        return try self.processResponse(response)
    }
    
    // SEARCH CARD
}
