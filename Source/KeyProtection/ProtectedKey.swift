//
// Copyright (C) 2015-2019 Virgil Security Inc.
//
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are
// met:
//
//     (1) Redistributions of source code must retain the above copyright
//     notice, this list of conditions and the following disclaimer.
//
//     (2) Redistributions in binary form must reproduce the above copyright
//     notice, this list of conditions and the following disclaimer in
//     the documentation and/or other materials provided with the
//     distribution.
//
//     (3) Neither the name of the copyright holder nor the names of its
//     contributors may be used to endorse or promote products derived from
//     this software without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE AUTHOR ''AS IS'' AND ANY EXPRESS OR
// IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
// WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT,
// INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
// HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
// STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING
// IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.
//
// Lead Maintainer: Virgil Security Inc. <support@virgilsecurity.com>
//

import Foundation

public class ProtectedKey {
    public let keyName: String
    public let accessTime: TimeInterval?
    public let keychainStorage: KeychainStorage
    
    public init(keyName: String, accessTime: TimeInterval?, keychainStorage: KeychainStorage) {
        self.keyName = keyName
        self.accessTime = accessTime
        self.keychainStorage = keychainStorage
    }
    
    private var timer: Timer?
    private var keychainEntry: KeychainEntry?
    
    @objc public func getKeychainEntry() throws -> KeychainEntry {
        if let keychainEntry = self.keychainEntry {
            return keychainEntry
        }
        
        let options = KeychainQueryOptions()
        options.biometricallyProtected = true
        
        let newKeychainEntry = try self.keychainStorage.retrieveEntry(withName: self.keyName, queryOptions: options)
        
        self.updateKeychainEntry(keychainEntry: newKeychainEntry)
        
        return newKeychainEntry
    }
    
    private func deleteKey() {
        self.timer = nil
        self.keychainEntry = nil
    }
    
    private func updateKeychainEntry(keychainEntry: KeychainEntry) {
        self.keychainEntry = keychainEntry
        
        if let accessTime = self.accessTime {
            let timer = Timer(interval: accessTime, repeating: false, startFromNow: true) { [weak self] in
                self?.deleteKey()
            }
            
            self.timer = timer
            timer.resume()
        }
    }
}
