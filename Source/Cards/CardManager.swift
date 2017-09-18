//
//  CardManager.swift
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 9/14/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

import Foundation
import VirgilCryptoAPI

@objc(VSSCardManager) public class CardManager: NSObject {
    private let crypto: Crypto
    private let client: CardClient
    private let validator: CardValidator
    
    public init(params: CardManagerParams) {
        self.crypto = params.crypto
        
//        let serviceConfig = VSSServiceConfig(token: params.apiToken)
//        serviceConfig.cardsServiceURL = params.apiUrl
        
        self.client = CardClient()
        self.validator = params.validator
    }
    
    public func getCard(withId cardId: String) throws -> Card {
        let rawCard = try self.client.getCard(withId: cardId)
        guard let card = Card.parse(crypto: self.crypto, rawCard: rawCard) else {
            // FIXME
            throw NSError()
        }
        
        // Validate
        
        return card
    }
    
    public func publishCard(csr: CSR) throws -> Card {
        let rawCard = try self.client.publishCard(request: csr.rawCard)
        guard let card = Card.parse(crypto: self.crypto, rawCard: rawCard) else {
            // FIXME
            throw NSError()
        }
        
        // Validate
        
        return card
    }
}
