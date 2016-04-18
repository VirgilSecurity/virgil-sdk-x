//
//  IPMSecurityManager.swift
//  IPMExample-swift
//
//  Created by Pavel Gorb on 4/18/16.
//  Copyright © 2016 Virgil Security, Inc. All rights reserved.
//

import UIKit

class IPMSecurityManager: NSObject {
    
    private(set) var identity: String
    private(set) var privateKey: VSSPrivateKey! = nil
    
    private var cardCache: NSMutableDictionary
    private var client: VSSClient

    private var clientSetUp: Bool
    private var mutex: NSObject
    
    private var actionId: String! = nil
    private var validationToken: String! = nil
    
    init(identity: String) {
        self.identity = identity
        
        self.cardCache = NSMutableDictionary()
        self.client = VSSClient(applicationToken: kAppToken)
        
        self.clientSetUp = false
        self.mutex = NSObject()
        
        super.init()
    }
    
    func cacheCardsForIdentities(identities: Array<String>) {
        if let error = XAsync.awaitResult(self.setup()) as? NSError {
            print("Error: \(error.localizedDescription)")
            return
        }
        
        XAsync.await { 
            let semaphore = dispatch_semaphore_create(0)
            
            var itemsCount = identities.count
            for identity in identities {
                if synchronized(self.mutex, closure: { () -> VSSCard? in
                    return self.cardCache[identity] as? VSSCard
                }) != nil {
                    itemsCount -= 1;
                    if itemsCount == 0 {
                        dispatch_semaphore_signal(semaphore)
                        return
                    }
                    continue
                }
                
                self.client.searchCardWithIdentityValue(identity, type: .Email, relations: nil, unconfirmed: nil, completionHandler: { cards, error in
                    if error != nil {
                        print("Error searching for card: \(error!.localizedDescription)")
                    }
                    else {
                        if let candidates = cards where candidates.count > 0 {
                            synchronized(self.mutex) {
                                self.cardCache[identity] = candidates[0]
                            }
                        }
                    }
                    
                    itemsCount -= 1;
                    if itemsCount == 0 {
                        dispatch_semaphore_signal(semaphore)
                        return
                    }
                })
            }
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
        }
    }
    
    func checkSignature(signature: NSData, data: NSData, identity: String) -> Bool {
        self.cacheCardsForIdentities([identity])
        
        var ok = false
        XAsync.await { 
            if let sender = synchronized(self.mutex, closure: {() -> VSSCard? in
                self.cardCache[identity] as? VSSCard
            }) {
                let verifier = VSSSigner()
                do {
                    try verifier.verifySignature(signature, data: data, publicKey: sender.publicKey.key, error: ())
                    ok = true
                }
                catch {
                    ok = false
                }
            }
        }
        return ok
    }
    
    func encryptData(data: NSData, identities: Array<String>) -> NSData? {
        self.cacheCardsForIdentities(identities)
        
        return XAsync.awaitResult({ () -> AnyObject? in
            let cryptor = VSSCryptor()
            for identity in identities {
                if let recipient = synchronized(self.mutex, closure: {() -> VSSCard? in
                    self.cardCache[identity] as? VSSCard
                }) {
                    do {
                        try cryptor.addKeyRecipient(recipient.Id, publicKey: recipient.publicKey.key, error: ())
                    }
                    catch {}
                }
            }
            
            return try? cryptor.encryptData(data, embedContentInfo: true, error: ())
        }) as? NSData
    }
    
    func decryptData(data: NSData) -> NSData? {
        self.cacheCardsForIdentities([self.identity])
        
        return XAsync.awaitResult({ () -> AnyObject? in
            if let recipient = synchronized(self.mutex, closure: { () -> VSSCard? in
                return self.cardCache[self.identity] as? VSSCard
            }) {
                let decryptor = VSSCryptor()
                return try? decryptor.decryptData(data, recipientId: recipient.Id, privateKey: self.privateKey.key, keyPassword: self.privateKey.password, error: ())
            }
            
            return nil
        }) as? NSData
    }
    
    func composeSignatureOnData(data: NSData) -> NSData? {
        return XAsync.awaitResult({ () -> AnyObject? in
            let signer = VSSSigner()
            return try? signer.signData(data, privateKey: self.privateKey.key, keyPassword: self.privateKey.password, error: ())
        }) as? NSData
    }
    
    
    func verifyIdentity() -> XAsyncActionResult {
        return { () -> AnyObject? in
            var actionError: NSError? = XAsync.awaitResult(self.setup()) as? NSError
            if actionError != nil {
                return actionError
            }
            
            let semaphore = dispatch_semaphore_create(0)
            self.client.verifyIdentityWithType(.Email, value: self.identity, completionHandler: { (actionId, error) in
                if error != nil {
                    actionError = error
                    dispatch_semaphore_signal(semaphore)
                    return
                }
                
                self.actionId = actionId
                actionError = nil
                dispatch_semaphore_signal(semaphore)
            })
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
            return actionError
        }
    }
    
    func confirmWithCode(code: String) -> XAsyncActionResult {
        return { () -> AnyObject? in
            var actionError: NSError? = XAsync.awaitResult(self.setup()) as? NSError
            if actionError != nil {
                return actionError
            }
            
            let semaphore = dispatch_semaphore_create(0)
            self.client.confirmIdentityWithActionId(self.actionId, code: code, ttl: nil, ctl: nil, completionHandler: { (type, value, validationToken, error) in
                if error != nil {
                    actionError = error
                    dispatch_semaphore_signal(semaphore)
                    return
                }
                
                self.validationToken = validationToken
                actionError = nil
                dispatch_semaphore_signal(semaphore)
            })
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
            return actionError
        }
    }
    
    func signin() -> XAsyncActionResult {
        return { () -> AnyObject? in
            var actionError: NSError? = XAsync.awaitResult(self.setup()) as? NSError
            if actionError != nil {
                return actionError
            }
            
            self.cacheCardsForIdentities([self.identity])

            if let card = synchronized(self.mutex, closure: { () -> VSSCard? in
                return self.cardCache[self.identity] as? VSSCard
            }) {
                let semaphore = dispatch_semaphore_create(0)
                let idict = [ kVSSModelValue: self.identity, kVSSModelType: VSSIdentity.stringFromIdentityType(.Email), kVSSModelValidationToken: self.validationToken]
                self.client.grabPrivateKeyWithIdentity(idict, cardId: card.Id, password: nil, completionHandler: { (keyData, cardId, error) in
                    if error != nil {
                        actionError = error
                        dispatch_semaphore_signal(semaphore)
                        return
                    }
                    
                    self.actionId = nil
                    self.validationToken = nil
                    self.privateKey = VSSPrivateKey(key: keyData!, password: nil)
                    actionError = nil
                    dispatch_semaphore_signal(semaphore)
                })
                dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
                return actionError
            }
            else {
                return NSError(domain: "SignInError", code: -5555, userInfo: [NSLocalizedDescriptionKey: NSLocalizedString("No cards found for given identity", comment: "")])
            }
        }
    }
    
    func signup() -> XAsyncActionResult {
        return { () -> AnyObject? in
            var actionError: NSError? = XAsync.awaitResult(self.setup()) as? NSError
            if actionError != nil {
                return actionError
            }
            
            let semaphore = dispatch_semaphore_create(0)
            let pair = VSSKeyPair(password: nil)
            self.privateKey = VSSPrivateKey(key: pair.privateKey(), password: nil)
            let idict = [kVSSModelValue: self.identity, kVSSModelType: VSSIdentity.stringFromIdentityType(.Email), kVSSModelValidationToken: self.validationToken]
            self.client.createCardWithPublicKey(pair.publicKey(), identity: idict, data: nil, signs: nil, privateKey: self.privateKey, completionHandler: { (card, error) in
                if error != nil || card == nil {
                    actionError = error
                    dispatch_semaphore_signal(semaphore)
                    return
                }
                
                synchronized(self.mutex) {
                    self.cardCache[self.identity] = card!
                }
                
                self.client.storePrivateKey(self.privateKey, cardId: card!.Id, completionHandler: { (error) in
                    if error != nil {
                        actionError = error
                        dispatch_semaphore_signal(semaphore)
                        return
                    }
                    
                    self.actionId = nil
                    self.validationToken = nil
                    actionError = nil
                    dispatch_semaphore_signal(semaphore)
                })
            })
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
            return actionError
        }
    }
    
    private func setup() -> XAsyncActionResult {
        return { () -> AnyObject? in
            if self.clientSetUp {
                return nil
            }
            
            var actionError: NSError! = nil
            let semaphore = dispatch_semaphore_create(0)
            self.client.setupClientWithCompletionHandler({ error in
                if error != nil {
                    actionError = error
                    dispatch_semaphore_signal(semaphore)
                    return
                }
                
                self.clientSetUp = true
                actionError = nil
                dispatch_semaphore_signal(semaphore)
            })
            
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
            return actionError
        }
    }
}
