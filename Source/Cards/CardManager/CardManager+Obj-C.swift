//
//  CardManager+Obj-C.swift
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 2/12/18.
//  Copyright © 2018 VirgilSecurity. All rights reserved.
//

import Foundation
import VirgilCryptoAPI

//objc compatable Queries
public extension CardManager {
    @objc func getCard(withId cardId: String, completion: @escaping (Card?, Error?) -> ()) {
        self.getCard(withId: cardId).start { result in
            switch result {
            case .success(let card):
                completion(card, nil)
            case .failure(let error):
                completion(nil, error)
            }
        }
    }

    @objc func publishCard(rawCard: RawSignedModel, timeout: NSNumber? = nil,
                           completion: @escaping (Card?, Error?) -> ()) {
        self.publishCard(rawCard: rawCard).start { result in
            switch result {
            case .success(let card):
                completion(card, nil)
            case .failure(let error):
                completion(nil, error)
            }
        }
    }

    @objc func publishCard(privateKey: PrivateKey, publicKey: PublicKey, identity: String,
                           previousCardId: String? = nil, extraFields: [String: String]? = nil,
                           completion: @escaping (Card?, Error?) -> ()) {
        do {
            try self.publishCard(privateKey: privateKey, publicKey: publicKey, identity: identity,
                                 previousCardId: previousCardId, extraFields: extraFields)
                .start { result in
                    switch result {
                    case .success(let card):
                        completion(card, nil)
                    case .failure(let error):
                        completion(nil, error)
                    }
                }
        } catch {
            completion(nil, error)
        }
    }

    @objc func searchCards(identity: String, completion: @escaping ([Card]?, Error?) -> ()) {
        self.searchCards(identity: identity).start { result in
            switch result {
            case .success(let cards):
                completion(cards, nil)
            case .failure(let error):
                completion(nil, error)
            }
        }
    }
}
