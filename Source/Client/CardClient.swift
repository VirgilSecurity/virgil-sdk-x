//
//  CardClient.swift
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 9/14/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

import Foundation

@objc(VSSCardClient) public class CardClient: NSObject {
    private let baseUrl: URL = URL(string: "")!
    private let connection: HTTPConnection = ServiceConnection()
    private let apiToken: String = ""
    
    private func handleError(statusCode: Int, body: Data?) -> Error {
        // FIXME
        return NSError()
    }
    
    public func getCard(withId cardId: String) throws -> RawCard {
        guard let url = URL(string: "card/\(cardId)", relativeTo: self.baseUrl) else {
            // FIXME
            throw NSError()
        }
        
        let request = ServiceRequest(url: url, method: .get, apiToken: self.apiToken)
        
        let response = try self.connection.send(request)
        
        guard response.statusCode == 200 else {
            throw self.handleError(statusCode: response.statusCode, body: response.body)
        }
        
        guard let data = response.body else {
            throw NSError()
        }
        
        guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [AnyHashable : Any] else {
            throw NSError()
        }
        
        guard let rawCard = RawCard(dict: json) else {
            throw NSError()
        }
        
        return rawCard
    }
    
    public func publishCard(request: RawCard) throws -> RawCard {
        guard let url = URL(string: "card", relativeTo: self.baseUrl) else {
            // FIXME
            throw NSError()
        }
        
        let request = ServiceRequest(url: url, method: .post, apiToken: self.apiToken)
        
        let response = try self.connection.send(request)
        
        guard response.statusCode == 200 else {
            throw self.handleError(statusCode: response.statusCode, body: response.body)
        }
        
        guard let data = response.body else {
            throw NSError()
        }
        
        guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [AnyHashable : Any] else {
            throw NSError()
        }
        
        guard let rawCard = RawCard(dict: json) else {
            throw NSError()
        }
        
        return rawCard
    }
    
    // SEARCH CARD
}
