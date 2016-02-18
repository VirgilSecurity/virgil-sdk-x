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
let kApplicationToken: String = "eyJpZCI6IjMyYTAwZDEwLWYyNTgtNDVjMi04YTQyLTY5OGFhYTU5NjhhNiIsImFwcGxpY2F0aW9uX2NhcmRfaWQiOiI2MTNiYTEwYy1lODQ5LTRkNTctODhlMy03YTZmZjdlZmVkYmEiLCJ0dGwiOi0xLCJjdGwiOi0xLCJwcm9sb25nIjowfQ==.MIGbMA0GCWCGSAFlAwQCAgUABIGJMIGGAkEAhcP5jjV88b/uRVwuILO8sCrqXElVLGrAi9YzHMxkp0rrDIjHtC7LKN3nGAs1z8N80yWHXDEpzv6YNiv6M9aoIgJBAJ+s8BOCDkMSdDoXN4G0KwQuzxWpm+x8Id1qEv+sYb1FRHlbpvwvJMH0kfMNwq42TwlGDvZTDQZRbN1N2OnX55k="
/// Virgil Application Token for testing applications
let kMailinatorToken: String = "3b0f46370d9f44cb9b5ac0e80dda97d7"
/// Each request should be done less than or equal this number of seconds.
let kEstimatedRequestCompletionTime: Int = 5
/// Time for waiting for the emails with confirmation codes sent by the Virgil Keys Service.
let kEstimatedEmailReceivingTime: Int = 2

class VSS001_ClientSwiftTests: XCTestCase {
    
    private var client: VSSClient! = nil
    private var mailinator: Mailinator! = nil
    
    private var regexp: NSRegularExpression! = nil
    
    private var keyPair: VSSKeyPair! = nil
    private var publicKey: VSSPublicKey! = nil
    
    private var card: VSSCard! = nil
    private var validationToken: String! = nil
    
    override func setUp() {
        super.setUp()

        self.client = VSSClient(applicationToken: kApplicationToken, serviceConfig: VSSServiceConfigStg())
        self.mailinator = Mailinator(applicationToken: kMailinatorToken, serviceConfig: MailinatorConfig())
        do {
            self.regexp = try NSRegularExpression(pattern: "Your confirmation code is.+([A-Z0-9]{6})", options: NSRegularExpressionOptions.CaseInsensitive)
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
        weak var ex = self.expectationWithDescription("Public key should be created and user data should be confirmed.")
        let numberOfRequests = 6
        let timeout = numberOfRequests * kEstimatedRequestCompletionTime + kEstimatedEmailReceivingTime
        
        self.client.setupClientWithCompletionHandler { (error) -> Void in
            if error != nil {
                XCTFail("Client has not been setup properly: \(error!.localizedDescription)")
                return
            }
            
            self.createConfirmedCardWithConfirmationHandler { (error) -> Void in
                if error != nil {
                    XCTFail("Error: \(error!.localizedDescription)")
                    return
                }
                
                XCTAssertNotNil(self.card, "Virgil Card should be created.")
                XCTAssertNotNil(self.card.Id, "Virgil Card should have ID.")
                XCTAssertTrue(self.card.isConfirmed.boolValue, "Virgil Card should be created confirmed.")
                
                ex?.fulfill()
            }
        }
        
        self.waitForExpectationsWithTimeout(NSTimeInterval(timeout)) { error in
            if error != nil {
                XCTFail("Expectation failed: \(error!.localizedDescription)")
            }
        }
    }
    
    func identityValue() -> String {
        let candidate = NSUUID().UUIDString.lowercaseString
        let identity = candidate.stringByReplacingOccurrencesOfString("-", withString: "")
        return "\(identity)@mailinator.com"
    }

    func identity() -> NSDictionary {
        return [ kVSSModelType: VSSIdentity.stringFromIdentityType(.Email), kVSSModelValue: self.identityValue()]
    }

    func createConfirmedCardWithConfirmationHandler(handler: ((NSError?) -> Void)?) {
        let identity = self.identity();
        self.client.verifyIdentityWithType(VSSIdentity.identityTypeFromString(identity[kVSSModelType] as? String), value: identity[kVSSModelValue] as! String) { (actionId, error) -> Void in
            if error != nil {
                if handler != nil {
                    handler!(error!)
                }
                return
            }
            
            self.confirmIdentity(identity, actionId: actionId!, handler: handler)
        }
    }
    
    func confirmIdentity(identity: NSDictionary, actionId: String, handler:((NSError?) -> Void)?) {
        let val = identity[kVSSModelValue] as! NSString
        let inbox = val.substringToIndex(val.rangeOfString("@").location)
        self.mailinator.getInbox(inbox) { (metadataList, error) -> Void in
            if error != nil {
                if handler != nil {
                    handler!(error!)
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
                        handler!(error!)
                    }
                    return
                }
                
                let bodyPart: MPart = email!.parts[0]
                // Try to find the actual confirmation code in body
                let matchResult = self.regexp.firstMatchInString(bodyPart.body, options: .ReportCompletion, range: NSMakeRange(0, bodyPart.body.characters.count))
                if matchResult == nil || matchResult!.range.location == NSNotFound {
                    // There is no match in the email body.
                    // Confirmation code is absent or can not be extracted.
                    if (handler != nil) {
                        handler!(NSError(domain: "TestDomain", code: -2, userInfo: nil))
                    }
                    return
                }
                // If we have a match
                let match = (bodyPart.body as NSString).substringWithRange(matchResult!.range)
                // Now match string should contain something like "Your confirmation code is ....."
                // Actual code is the last 6 charachters.
                // Extract the code
                let code = (match as NSString).substringFromIndex(match.characters.count - 6);
                self.client.confirmIdentityWithActionId(actionId, code: code, ttl: nil, ctl: 10, completionHandler: { (itype, ivalue, ivalToken, error) -> Void in
                    if error != nil {
                        if handler != nil {
                            handler!(error!)
                        }
                        return
                    }
                    
                    if identity[kVSSModelValue] as? String != ivalue || ivalToken?.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) == 0 {
                        if (handler != nil) {
                            handler!(NSError(domain: "TestDomain", code: -3, userInfo: nil))
                        }
                        return
                    }
                    self.validationToken = ivalToken
                    let identityExt = NSMutableDictionary(dictionary: identity)
                    identityExt[kVSSModelValidationToken] = ivalToken!
                    
                    let privateKey = VSSPrivateKey(key: self.keyPair.privateKey(), password: nil)
                    self.client.createCardWithPublicKey(self.keyPair.publicKey(), identity: identityExt as [NSObject : AnyObject], data: nil, signs: nil, privateKey: privateKey, completionHandler: { (card, error) -> Void in
                        self.card = card
                        if handler != nil {
                            handler!(error)
                        }
                        return
                    })
                })
            })
            
        }
    }
    
}
