//
//  RawServiceError.swift
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 9/20/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

import Foundation

public final class RawServiceError: Deserializable {
    public let code: Int
    public let message: String
}
