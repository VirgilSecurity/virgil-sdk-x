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
let kApplicationToken: String = "eyJpZCI6IjAwOTUwMWFjLWNlZmYtNDRhZC1iMGI2LTk0ZjlkYjJmYzY1YiIsImFwcGxpY2F0aW9uX2NhcmRfaWQiOiIxNTJhOGM3Yi03MDNmLTRmYWMtOTcxYi02MDcyMjNjZTc1NjAiLCJ0dGwiOi0xLCJjdGwiOi0xLCJwcm9sb25nIjowfQ==.MFgwDQYJYIZIAWUDBAICBQAERzBFAiAi1tiSdVSU6ZP8U7jRv2cN+jxkqvhrjpmT0ejIgnB/AQIhAM6H13yqn5xpkkC+GJ//aa1rS/84kpoBleDLTmv/KTge"
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

        self.client = VSSClient(applicationToken: kApplicationToken)
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
        
        self.createConfirmedCardWithConfirmationHandler { (error) -> Void in
            if error != nil {
                XCTFail("Error: \(error!.localizedDescription)")
                return
            }
            
            XCTAssertNotNil(self.card, "Virgil Card should be created.")
            XCTAssertNotNil(self.card.Id, "Virgil Card should have ID.")
            XCTAssertTrue(self.card.isConfirmed.boolValue, "Virgil Card should be created confirmed.")
            XCTAssertNotNil(self.card.createdAt, "Virgil Card should contain correct date of creation.")
            
            ex?.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(NSTimeInterval(timeout)) { error in
            if error != nil {
                XCTFail("Expectation failed: \(error!.localizedDescription)")
            }
        }
    }
    
    func identityValue() -> String {
        let guid = NSUUID().UUIDString.lowercaseString
        let candidate = guid.stringByReplacingOccurrencesOfString("-", withString: "")
        let identity = candidate.substringToIndex(candidate.startIndex.advancedBy(25))
        return "\(identity)@mailinator.com"
    }

    func identity() -> VSSIdentityInfo {
        return VSSIdentityInfo(type: .Email, value: self.identityValue(), validationToken: nil)
    }

    func createConfirmedCardWithConfirmationHandler(handler: ((NSError?) -> Void)?) {
        let identity = self.identity();
        
        self.client.verifyIdentityWithInfo(identity, extraFields: nil) { (actionId, error) -> Void in
            if error != nil {
                if handler != nil {
                    handler!(error!)
                }
                return
            }
            
            self.confirmIdentity(identity, actionId: actionId!, handler: handler)
        }
    }
    
    func confirmIdentity(identity: VSSIdentityInfo, actionId: String, handler:((NSError?) -> Void)?) {
        let value = identity.value as NSString
        let inbox = value.substringToIndex(value.rangeOfString("@").location)
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
                self.client.confirmIdentityWithActionId(actionId, code: code, tokenTtl: 0, tokenCtl: 10) { identityInfo, error in
                    if error != nil {
                        if handler != nil {
                            handler!(error!)
                        }
                        return
                    }
                    
                    if identityInfo == nil || !identity.isEqual(identityInfo!) || identityInfo!.validationToken?.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) == 0 {
                        if (handler != nil) {
                            handler!(NSError(domain: "TestDomain", code: -3, userInfo: nil))
                        }
                        return
                    }
                    
                    self.validationToken = identityInfo!.validationToken
                    identity.validationToken = identityInfo!.validationToken
                    
                    let privateKey = VSSPrivateKey(key: self.keyPair.privateKey(), password: nil)
                    self.client.createCardWithPublicKey(self.keyPair.publicKey(), identityInfo: identityInfo!, data: nil, signs: nil, privateKey: privateKey) { card, error in
                    
                        self.card = card
                        if handler != nil {
                            handler!(error)
                        }
                        return
                    }
                }
            })
            
        }
    }
    
}
