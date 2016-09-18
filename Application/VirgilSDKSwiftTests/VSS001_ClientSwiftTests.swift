//
//  VK001_KeysClientSwiftTests.swift
//  VirgilKeys
//
//  Created by Pavel Gorb on 9/29/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

import Foundation
import XCTest

/// Virgil Application Token for testing applications
//let kApplicationToken: String = <# String: Virgil Application Token #>
/// Virgil Application Token for testing applications
//let kMailinatorToken: String = <# String: Mailinator Token #>
/// Each request should be done less than or equal this number of seconds.
let kEstimatedRequestCompletionTime: Int = 5
/// Time for waiting for the emails with confirmation codes sent by the Virgil Keys Service.
let kEstimatedEmailReceivingTime: Int = 2

class VSS001_ClientSwiftTests: XCTestCase {
    
    fileprivate var client: VSSClient! = nil
    fileprivate var mailinator: Mailinator! = nil
    
    fileprivate var regexp: NSRegularExpression! = nil
    
    fileprivate var keyPair: VSSKeyPair! = nil
    fileprivate var publicKey: VSSPublicKey! = nil
    
    fileprivate var card: VSSCard! = nil
    fileprivate var validationToken: String! = nil
    
    override func setUp() {
        super.setUp()

        // FIXME: Put proper app token
        self.client = VSSClient(applicationToken: "")
        // FIXME: Put proper mailinator token
        self.mailinator = Mailinator(applicationToken: "", serviceConfig: MailinatorConfig())
        do {
            self.regexp = try NSRegularExpression(pattern: "Your confirmation code is.+([A-Z0-9]{6})", options: NSRegularExpression.Options.caseInsensitive)
        }
        catch {
            self.regexp = nil
        }
        self.keyPair = VSSKeyPair(password: nil)
    }

    override func tearDown() {
        self.client = nil;
        self.mailinator = nil;
        self.regexp = nil;
        self.keyPair = nil;
        self.publicKey = nil;
        
        super.tearDown()
    }
    
    func test001_createCardAndConfirmIdentity() {
        weak var ex = self.expectation(description: "Public key should be created and user data should be confirmed.")
        let numberOfRequests = 6
        let timeout = numberOfRequests * kEstimatedRequestCompletionTime + kEstimatedEmailReceivingTime
        
        self.createConfirmedCardWithConfirmationHandler { (error) -> Void in
            if error != nil {
                XCTFail("Error: \(error!.localizedDescription)")
                return
            }
            
            XCTAssertNotNil(self.card, "Virgil Card should be created.")
            XCTAssertNotNil(self.card.id, "Virgil Card should have ID.")
            XCTAssertNotNil(self.card.authorizedBy, "Virgil Card should be created confirmed.")
            XCTAssertNotNil(self.card.createdAt, "Virgil Card should contain correct date of creation.")
            
            ex?.fulfill()
        }
        
        self.waitForExpectations(timeout: TimeInterval(timeout)) { error in
            if error != nil {
                XCTFail("Expectation failed: \(error!.localizedDescription)")
            }
        }
    }
    
    func identityValue() -> String {
        let guid = NSUUID().uuidString.lowercased()
        let candidate = guid.replacingOccurrences(of: "-", with: "")
        let identity = candidate.substring(to: candidate.characters.index(candidate.startIndex, offsetBy: 25))
        return "\(identity)@mailinator.com"
    }

    func identity() -> VSSIdentityInfo {
        return VSSIdentityInfo(type: kVSSIdentityTypeEmail, value: self.identityValue(), validationToken: nil)
    }

    func createConfirmedCardWithConfirmationHandler(_ handler: ((NSError?) -> Void)?) {
        let identity = self.identity();
        
        self.client.verifyEmailIdentity(withValue: identity.value, extraFields: nil) { (actionId, error) in
            if error != nil {
                if handler != nil {
                    handler!(error! as NSError?)
                }
                return
            }
            
            self.confirmIdentity(identity, actionId: actionId!, handler: handler)
        }
    }
    
    func confirmIdentity(_ identity: VSSIdentityInfo, actionId: String, handler:((NSError?) -> Void)?) {
        let value = identity.value as NSString
        let inbox = value.substring(to: value.range(of: "@").location)
        self.mailinator.getInbox(inbox) { (metadataList, error) -> Void in
            if error != nil {
                if handler != nil {
                    handler!(error! as NSError?)
                }
                return
            }
            
            if metadataList?.count == 0 {
                if (handler != nil) {
                    handler!(NSError(domain: "TestDomain", code: -1, userInfo: nil))
                }
                return
            }
            
            let metadata: MEmailMetadata = metadataList![0] as! MEmailMetadata
            self.mailinator.getEmail(metadata.mid, completionHandler: { (email, error) -> Void in
                if error != nil {
                    if handler != nil {
                        handler!(error! as NSError?)
                    }
                    return
                }
                
                let bodyPart: MPart = email!.parts[0]
                // Try to find the actual confirmation code in body
                let matchResult = self.regexp.firstMatch(in: bodyPart.body, options: .reportCompletion, range: NSMakeRange(0, bodyPart.body.characters.count))
                if matchResult == nil || matchResult!.range.location == NSNotFound {
                    // There is no match in the email body.
                    // Confirmation code is absent or can not be extracted.
                    if (handler != nil) {
                        handler!(NSError(domain: "TestDomain", code: -2, userInfo: nil))
                    }
                    return
                }
                // If we have a match
                let match = (bodyPart.body as NSString).substring(with: matchResult!.range)
                // Now match string should contain something like "Your confirmation code is ....."
                // Actual code is the last 6 charachters.
                // Extract the code
                let code = (match as NSString).substring(from: match.characters.count - 6);
                self.client.confirmEmailIdentity(withActionId: actionId, code: code, tokenTtl: 0, tokenCtl: 10, completionHandler: { (identityInfo, error) in
                    if error != nil {
                        if handler != nil {
                            handler!(error! as NSError?)
                        }
                        return
                    }
                    
                    if identityInfo == nil || !identity.isEqual(identityInfo!) || identityInfo!.validationToken?.lengthOfBytes(using: String.Encoding.utf8) == 0 {
                        if (handler != nil) {
                            handler!(NSError(domain: "TestDomain", code: -3, userInfo: nil))
                        }
                        return
                    }
                    
                    self.validationToken = identityInfo!.validationToken
                    identity.validationToken = identityInfo!.validationToken
                    
                    let privateKey = VSSPrivateKey(key: self.keyPair.privateKey(), password: nil)
                    self.client.createCard(withPublicKey: self.keyPair.publicKey(), identityInfo: identityInfo!, data: nil, privateKey: privateKey) { card, error in
                        
                        self.card = card
                        if handler != nil {
                            handler!(error as NSError?)
                        }
                        return
                    }
                })
            })
            
        }
    }
    
}
