//
//  RawServiceError.swift
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 9/20/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

import Foundation

/// Model for representing service errors
public final class RawServiceError: Decodable {
    /// Code of error
    public let code: Int
    /// Description of error
    public let message: String
}
