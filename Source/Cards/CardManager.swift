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
    private let crypto: CardCrypto
    private let client: CardClient
    private let validator: CardVerifier?
    
    @objc public init(params: CardManagerParams) {
        self.crypto = params.crypto
        self.client = CardClient(baseUrl: params.apiUrl, apiToken: params.apiToken)
        self.validator = params.validator
    }
    
    private func validateCard(_ card: Card) throws {
        if let validator = self.validator {
            let result = validator.verifyCard(card: card)
            guard result.isValid else {
                throw NSError()
            }
        }
    }
    
    @objc public func getCard(withId cardId: String) throws -> Card {
        let rawCard = try self.client.getCard(withId: cardId)
        guard let card = Card.parse(crypto: self.crypto, rawCard: rawCard) else {
            // FIXME
            throw NSError()
        }
        
        try self.validateCard(card)
        
        return card
    }
    
    @objc public func publishCard(csr: CSR) throws -> Card {
        let rawCard = try self.client.publishCard(request: csr.rawCard)
        guard let card = Card.parse(crypto: self.crypto, rawCard: rawCard) else {
            // FIXME
            throw NSError()
        }
        
        try self.validateCard(card)
        
        return card
    }
}
