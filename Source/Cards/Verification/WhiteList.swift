//
//  WhiteList.swift
//  VirgilSDK
//
//  Created by Eugen Pivovarov on 1/11/18.
//  Copyright © 2018 VirgilSecurity. All rights reserved.
//

import Foundation

@objc(VSSWhiteListError) public enum WhiteListError: Int, Error {
    case duplicateSigner = 1
}

@objc(VSSWhiteList) public class WhiteList: NSObject {
    @objc public let verifiersCredentials: [VerifierCredentials]

    @objc public init(verifiersCredentials: [VerifierCredentials]) throws {
        self.verifiersCredentials = verifiersCredentials

        let signers = self.verifiersCredentials.map { $0.signer }

        for signer in signers {
            guard signers.filter({ $0 == signer }).count < 2 else {
                throw WhiteListError.duplicateSigner
            }
        }

        super.init()
    }
}
