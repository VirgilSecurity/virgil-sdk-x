//
//  AppState.swift
//  VirgilFirebaseChat
//
//  Created by Pavel Gorb on 6/17/16.
//  Copyright © 2016 Virgil Security, Inc. All rights reserved.
//

import Foundation

class AppState: NSObject {
    
    var cards = [String: VSSCard]()
    var identity: String! = nil
    var privateKey: VSSPrivateKey! = nil
    
    func kill() {
        self.cards = [String: VSSCard]()
        self.identity = nil
        self.privateKey = nil
    }
}

// MARK: Singletone implementation
extension AppState {
    class var sharedInstance: AppState {
        struct Static {
            static var onceToken: dispatch_once_t = 0
            static var instance: AppState? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = AppState()
        }
        return Static.instance!
    }
}
