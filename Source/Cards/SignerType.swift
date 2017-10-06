//
//  SignerType.swift
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 9/15/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

import Foundation

@objc(VSSSignerType) public enum SignerType: Int {
    case `self`
    case application
    case virgil
    case custom
    
    enum SignerTypeInternal: String {
        case `self`      = "self"
        case application = "application"
        case virgil      = "virgil"
        case custom      = "custom"
        
        init(internal: SignerType) {
            switch `internal` {
            case .self: self = .self
            case .application: self = .application
            case .virgil: self = .virgil
            case .custom: self = .custom
            }
        }
        
        var external: SignerType {
            switch self {
            case .self: return .self
            case .application: return .application
            case .virgil: return .virgil
            case .custom: return .custom
            }
        }
    }
    
    private var `internal`: SignerTypeInternal { return SignerTypeInternal(internal: self) }
    
    init?(from string: String) {
        guard let `internal` = SignerTypeInternal(rawValue: string) else {
            return nil
        }
        
        self = `internal`.external
    }
    
    func toString() -> String {
        return self.internal.rawValue
    }
}
