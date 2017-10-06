//
//  RawServiceError.swift
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 9/20/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

import Foundation

public final class RawServiceError: Deserializable {
    let code: Int
    let message: String
    
    required public init?(dict: Any) {
        guard let candidate = dict as? [AnyHashable : Any] else {
            return nil
        }
        
        guard let code = candidate["code"] as? Int,
            let message = candidate["message"] as? String else {
                return nil
        }
        
        self.code = code
        self.message = message
    }
}
