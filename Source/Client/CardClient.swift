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
    
    public func getCard(withId cardId: String, completion: @escaping (RawCard?, Error?) -> ()) {
        guard let url = URL(string: "card/\(cardId)", relativeTo: self.baseUrl) else {
            // FIXME
            return
        }
        
        let request = ServiceRequest(url: url, method: .get, apiToken: self.apiToken)
        
        do {
            let response = try self.connection.send(request)
            
            guard response.statusCode == 200 else {
                let error = self.handleError(statusCode: response.statusCode, body: response.body)
                completion(nil, error)
                return
            }
            
            guard let data = response.body else {
                completion(nil, NSError())
                return
            }
            
            guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [AnyHashable : Any] else {
                completion(nil, NSError())
                return
            }
            
            guard let rawCard = RawCard(dict: json) else {
                completion(nil, NSError())
                return
            }
            
            completion(rawCard, nil)
            return
        }
        catch {
            completion(nil, error)
            return
        }
    }
}
