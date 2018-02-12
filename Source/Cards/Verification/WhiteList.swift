//
//  WhiteList.swift
//  VirgilSDK
//
//  Created by Eugen Pivovarov on 1/11/18.
//  Copyright © 2018 VirgilSecurity. All rights reserved.
//

import Foundation

@objc(VSSWhiteList) public class WhiteList: NSObject {
    @objc public let verifiersCredentials: [VerifierCredentials]

    @objc public init(verifiersCredentials: [VerifierCredentials]) {
        self.verifiersCredentials = verifiersCredentials

        super.init()
    }
}
