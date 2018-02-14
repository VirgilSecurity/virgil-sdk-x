//
//  CardClientProtocol.swift
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 2/13/18.
//  Copyright © 2018 VirgilSecurity. All rights reserved.
//

import Foundation

@objc(VSSCardClientProtocol) public protocol CardClientProtocol: class {
    @objc func getCard(withId cardId: String, token: String) throws -> GetCardResponse
    @objc func publishCard(model: RawSignedModel, token: String) throws -> RawSignedModel
    @objc func searchCards(identity: String, token: String) throws -> [RawSignedModel]
}
