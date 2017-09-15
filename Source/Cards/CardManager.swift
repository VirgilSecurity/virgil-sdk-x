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
    // FIXME
//    private let validator: 
    
    public init(params: CardManagerParams) {
        self.crypto = params.crypto
        
//        let serviceConfig = VSSServiceConfig(token: params.apiToken)
//        serviceConfig.cardsServiceURL = params.apiUrl
        
        self.client = CardClient()
    }
    
//    public func getCard(withId cardId: String, completion: @escaping (VSSCard?, Error?) -> ()) {
//        
//    }
    
//    public func publishCard(csr: CSR) throws -> Card {
//        let rawCard = try self.client.publishCard(request: csr.rawCard)
//        
//        
//    }
}
