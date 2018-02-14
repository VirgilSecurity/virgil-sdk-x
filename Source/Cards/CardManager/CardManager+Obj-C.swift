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
    /// Asynchronously returns `GetCardResponse` with `RawSignedModel` of card
    /// from the Virgil Cards Service with given ID, if exists
    ///
    /// - Parameters:
    ///   - cardId: string with unique Virgil Card identifier
    ///   - completion: completion handler, called with founded and verified Card or corresponding error
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

    /// Creates Virgil Card instance on the Virgil Cards Service and associates it with unique identifier
    /// Also makes the Card accessible for search/get queries from other users
    /// `RawSignedModel` should be at least selfSigned
    ///
    /// - Parameters:
    ///   - model: self signed `RawSignedModel`
    ///   - token: string with `Access Token`
    /// - Returns: `RawSignedModel` of created card
    /// - Throws: corresponding error

    /// Asynchronously creates Virgil Card instance on the Virgil Cards Service and associates it with unique identifier
    /// Also makes the Card accessible for search/get queries from other users
    /// `RawSignedModel` should be at least selfSigned
    ///
    /// - Parameters:
    ///   - rawCard: self signed `RawSignedModel`
    ///   - completion: completion handler, called with published and verified Card or corresponding error
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


    /// Asynchronously generates self signed RawSignedModel and creates Virgil Card
    /// instance on the Virgil Cards Service and associates it with unique identifier
    ///
    /// - Parameters:
    ///   - privateKey: Private Key to self sign RawSignedModel with
    ///   - publicKey: PublicKey for generating RawSignedModel
    ///   - identity: identity for generating RawSignedModel. Will be taken from token if ommited
    ///   - previousCardId: identifier of Virgil Card to replace
    ///   - extraFields: Dictionary with extra data to sign with model
    ///   - completion: completion handler, called with published and verified Card or corresponding error
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

    /// Performs search of Virgil Cards using identity on the Virgil Cards Service
    ///
    /// - Parameters:
    ///   - identity: identity of cards to search
    ///   - token: string with `Access Token`
    /// - Returns: array with RawSignedModels of matched Virgil Cards
    /// - Throws: corresponding error

    /// Asynchronously performs search of Virgil Cards using identity on the Virgil Cards Service
    ///
    /// - Parameters:
    ///   - identity: identity of cards to search
    ///   - completion: completion handler, called with founded and verified Cards or corresponding error
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
