//
//  Result.swift
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 2/18/18.
//  Copyright © 2018 VirgilSecurity. All rights reserved.
//

import Foundation

/// Represents operation result
///
/// - success: Operation has succeeded
/// - failure: Operation has failed
public enum Result<T> {
    case success(T)
    case failure(Error)
}
