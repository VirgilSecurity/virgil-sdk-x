//
//  ValidationResult.swift
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 9/18/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

import Foundation

@objc(VSSValidationResult) public class ValidationResult: NSObject {
    public private(set) var errors: [Error] = []
    
    public var isValid: Bool { return self.errors.count == 0 }
    
    func addError(_ error: Error) {
        self.errors.append(error)
    }
    
}
