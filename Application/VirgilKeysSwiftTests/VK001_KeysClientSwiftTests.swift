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
let kApplicationToken: String = "e872d6f718a2dd0bd8cd7d7e73a25f49"
/// Virgil Application Token for testing applications
let kMailinatorToken: String = "3b0f46370d9f44cb9b5ac0e80dda97d7"
/// Number of user data objects associated with/attached to the public key.
let kTestUserDataCount: Int = 2
/// Each request should be done less than or equal this number of seconds.
let kEstimatedRequestCompletionTime: Int = 5
/// Time for waiting for the emails with confirmation codes sent by the Virgil Keys Service.
let kEstimatedEmailReceivingTime: Int = 2

class VK001_KeysClientSwiftTests: XCTestCase {
    
    private var keysClient: VKKeysClientStg! = nil
    private var mailinator: Mailinator! = nil
    
    private var regexp: NSRegularExpression! = nil
    
    private var keyPair: VCKeyPair! = nil
    private var publicKey: VKPublicKey! = nil
    
    override func setUp() {
        super.setUp()

        self.keysClient = VKKeysClientStg(applicationToken: kApplicationToken)
        self.mailinator = Mailinator(applicationToken: kMailinatorToken)
        do {
            self.regexp = try NSRegularExpression(pattern: "Your confirmation code is.+([A-Z0-9]{6})", options: NSRegularExpressionOptions.CaseInsensitive)
        }
        catch {
            self.regexp = nil
        }
        self.keyPair = VCKeyPair(password: nil)
    }
    
    override func tearDown() {
        self.keysClient = nil;
        self.mailinator = nil;
        self.regexp = nil;
        self.keyPair = nil;
        self.publicKey = nil;
        
        super.tearDown()
    }
    
    func test001_createPublicKeyAndConfirmUserData() {
        let ex = self.expectationWithDescription("Public key should be created and user data should be confirmed.")
        let numberOfRequests = kTestUserDataCount * 3 + 1
        let timeout = numberOfRequests * kEstimatedRequestCompletionTime + kEstimatedEmailReceivingTime
        
        let userDataList = self.userDataListWithLength(kTestUserDataCount)
        self.createPublicKeyWithUserDataList(userDataList, confirmUserDataWithHandler: { error in
            if error != nil {
                XCTFail("Error: \(error!.localizedDescription)")
                return
            }
            
            XCTAssertNotNil(self.publicKey, "Public key should be created successfully.")
            ex.fulfill()
        })
        
        self.waitForExpectationsWithTimeout(NSTimeInterval(timeout), handler: { error in
            if error != nil {
                XCTFail("Expectation failed: \(error!.localizedDescription)")
            }
        })
    }
    
    func test002_getExistingPublicKey() {
        let ex = self.expectationWithDescription("Public key should be get after creation.")
        let numberOfRequests = kTestUserDataCount * 3 + 1 + 1
        let timeout = numberOfRequests * kEstimatedRequestCompletionTime + kEstimatedEmailReceivingTime
        
        let userDataList = self.userDataListWithLength(kTestUserDataCount)
        self.createPublicKeyWithUserDataList(userDataList, confirmUserDataWithHandler: { error in
            if error != nil {
                XCTFail("Error: \(error!.localizedDescription)")
                return
            }
            
            self.keysClient.getPublicKeyId(self.publicKey.idb.publicKeyId, completionHandler: { pubKey, getError in
                if getError != nil {
                    XCTFail("Error getting the key: \(getError!.localizedDescription)")
                    return
                }
                
                XCTAssertNotNil(pubKey, "Public key should be get successfully")
                XCTAssertNotNil(pubKey.key, "Actual key data should be returned within Public Key structure.")
                ex.fulfill()
            })
        })
        
        
        self.waitForExpectationsWithTimeout(NSTimeInterval(timeout), handler: { error in
            if error != nil {
                XCTFail("Expectation failed: \(error!.localizedDescription)")
            }
        })
    }
    
    func test003_updateExistingPublicKey() {
        let newKeyPair = VCKeyPair()
        
        let ex = self.expectationWithDescription("Public key should be get after creation.")
        let numberOfRequests = kTestUserDataCount * 3 + 1 + 1
        let timeout = numberOfRequests * kEstimatedRequestCompletionTime + kEstimatedEmailReceivingTime
        
        let userDataList = self.userDataListWithLength(kTestUserDataCount)
        self.createPublicKeyWithUserDataList(userDataList, confirmUserDataWithHandler: { error in
            if error != nil {
                XCTFail("Error: \(error!.localizedDescription)")
                return
            }
            
            self.keysClient.updatePublicKeyId(self.publicKey.idb.publicKeyId, privateKey: self.keyPair.privateKey(), keyPassword: nil, newKeyPair: newKeyPair, newKeyPassword: nil, completionHandler: { pubKey, updateError in
                if updateError != nil {
                    XCTFail("Error updating public key: \(updateError!.localizedDescription)")
                    return
                }
                
                XCTAssertNotEqual(self.publicKey.key, pubKey.key, "Public key data should be updated.")
                XCTAssertEqual(newKeyPair.publicKey(), pubKey.key, "Updated public key should contain the exact data which was generated in the new key pair.")
                ex.fulfill()
            })
        })
        
        self.waitForExpectationsWithTimeout(NSTimeInterval(timeout), handler: { error in
            if error != nil {
                XCTFail("Expectation failed: \(error!.localizedDescription)")
            }
        })
    }
    
    func test004_deleteExistingPublicKey() {
        let ex = self.expectationWithDescription("Public key should be deleted.")
        let numberOfRequests = kTestUserDataCount * 3 + 1 + 1 + 1
        let timeout = numberOfRequests * kEstimatedRequestCompletionTime + kEstimatedEmailReceivingTime
        
        let userDataList = self.userDataListWithLength(kTestUserDataCount)
        self.createPublicKeyWithUserDataList(userDataList, confirmUserDataWithHandler: { error in
            if error != nil {
                XCTFail("Error: \(error!.localizedDescription)")
                return
            }
            
            self.keysClient.deletePublicKeyId(self.publicKey.idb.publicKeyId, privateKey: self.keyPair.privateKey(), keyPassword: nil, completionHandler: { actionToken, deleteError in
                if deleteError != nil {
                    XCTFail("Public key should be successfully deleted.")
                    return
                }
                
                self.keysClient.getPublicKeyId(self.publicKey.idb.publicKeyId, completionHandler: { pubKey, getError in
                    if getError != nil {
                        ex.fulfill()
                        return
                    }
                    
                    XCTFail("Public key should not be get after deletion.")
                    return
                })
            })
        })
        
        self.waitForExpectationsWithTimeout(NSTimeInterval(timeout), handler: { error in
            if error != nil {
                XCTFail("Expectation failed: \(error!.localizedDescription)")
            }
        })
    }
    
    func test005_addUserDataToExistingPublicKey() {
        let ex = self.expectationWithDescription("User data entity should be added.")
        let numberOfRequests = 3 + 1 + 1 + 1
        let timeout = numberOfRequests * kEstimatedRequestCompletionTime + kEstimatedEmailReceivingTime
        
        let userDataList = self.userDataListWithLength(1)
        self.createPublicKeyWithUserDataList(userDataList, confirmUserDataWithHandler: { error in
            if error != nil {
                XCTFail("Error: \(error!.localizedDescription)")
                return
            }
            
            let userDataList1 = self.userDataListWithLength(1)
            let ud = userDataList1[0] as! VKUserData
            self.keysClient.createUserData(ud, publicKeyId: self.publicKey.idb.publicKeyId, privateKey: self.keyPair.privateKey(), keyPassword: nil, completionHandler: { userData, createError in
                if createError != nil {
                    XCTFail("Error: \(createError!.localizedDescription)")
                    return
                }
                
                self.keysClient.getPublicKeyId(self.publicKey.idb.publicKeyId, completionHandler: { pubKey, getError in
                    if getError != nil {
                        XCTFail("Error: \(getError!.localizedDescription)")
                        return
                    }
                    
                    XCTAssertTrue(pubKey.userDataList.count - self.publicKey.userDataList.count == 1, "Public key should now have one additional user data.")
                    
                    ex.fulfill()
                })
            })
        })
        
        self.waitForExpectationsWithTimeout(NSTimeInterval(timeout), handler: { error in
            if error != nil {
                XCTFail("Expectation failed: \(error!.localizedDescription)")
            }
        })
    }
    
    func test007_deleteUserDataFromExistingPublicKey() {
        let ex = self.expectationWithDescription("User data entity should be removed.")
        let numberOfRequests = kTestUserDataCount * 3 + 1 + 1 + 1
        let timeout = numberOfRequests * kEstimatedRequestCompletionTime + kEstimatedEmailReceivingTime
        
        let userDataList = self.userDataListWithLength(kTestUserDataCount)
        self.createPublicKeyWithUserDataList(userDataList, confirmUserDataWithHandler: { error in
            if error != nil {
                XCTFail("Error: \(error!.localizedDescription)")
                return
            }
            
            let ud = userDataList[0] as! VKUserData
            self.keysClient.deleteUserDataId(ud.idb.userDataId, publicKeyId: self.publicKey.idb.publicKeyId, privateKey: self.keyPair.privateKey(), keyPassword: nil, completionHandler: { deleteError in
                if deleteError != nil {
                    XCTFail("Error: \(deleteError!.localizedDescription)")
                    return
                }
                
                self.keysClient.getPublicKeyId(self.publicKey.idb.publicKeyId, completionHandler: { pubKey, getError in
                    if getError != nil {
                        XCTFail("Error: \(getError!.localizedDescription)")
                        return
                    }
                    
                    XCTAssertTrue(self.publicKey.userDataList.count - pubKey.userDataList.count == 1, "Public key should now have one additional user data less than initially created.")
                    
                    ex.fulfill()
                })
            })
        })
        
        self.waitForExpectationsWithTimeout(NSTimeInterval(timeout), handler: { error in
            if error != nil {
                XCTFail("Expectation failed: \(error!.localizedDescription)")
            }
        })
    }
    
}

extension VK001_KeysClientSwiftTests {

    func userDataValue() -> String {
        let candidate = NSUUID().UUIDString as NSString;
        let userId = candidate.stringByReplacingOccurrencesOfString("-", withString: "")
        return "\(userId)@mailinator.com"
    }

    func userData() -> VKUserData {
        return VKUserData(idb: nil, dataClass: .UDCUserId, dataType: .UDTEmail, value: self.userDataValue(), confirmed: false)
    }

    func userDataListWithLength(length: Int) -> NSArray {
        let list = NSMutableArray(capacity: length)
        for _ in 0..<length {
            list.addObject(self.userData())
        }
        return list;
    }

    func completedConfirmationList(list: NSArray) -> Bool {
        for conf in list {
            if !(conf as! NSNumber).boolValue {
                return false
            }
        }
        
        return true
    }
    
    func createPublicKeyWithUserDataList(list: NSArray, handler: ((NSError?) -> Void)?) {
        let pKey = VKPublicKey(idb: nil, key: self.keyPair.publicKey(), userDataList: list as [AnyObject])
        self.keysClient.createPublicKey(pKey, privateKey: self.keyPair.privateKey(), keyPassword: nil) { pubKey, error in
            if error != nil {
                if handler != nil {
                    handler!(error!)
                }
                return
            }
            
            self.publicKey = pubKey
            if handler != nil {
                handler!(nil)
            }
        }
    }
    
    func confirmUserDataOfPublicKey(pKey: VKPublicKey, handler: ((NSError?)->Void)?) {
        let confirmationList = NSMutableArray(capacity: pKey.userDataList.count)
        for i in 0..<pKey.userDataList.count {
            confirmationList[i] = false
        }
        
        for i in 0..<pKey.userDataList.count {
            let ud = pKey.userDataList[i] as! VKUserData
            let inbox = (ud.value as NSString).substringToIndex((ud.value as NSString).rangeOfString("@").location)

            let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (Int64)(1 * NSEC_PER_SEC)), queue, { () -> Void in
                self.mailinator.getInbox(inbox, completionHandler: { metadataList, inboxError in
                    if inboxError != nil {
                        if handler != nil {
                            handler!(inboxError!)
                        }
                        return
                    }
                    if metadataList.count == 0 {
                        // But there is no any mails in the inbox.
                        // We can't get the confirmation code.
                        if (handler != nil) {
                            handler!(NSError(domain: "TestDomain", code: -1, userInfo: nil))
                        }
                        return
                    }
                    // Get the latest metadata from the list (it is the first object)
                    let metadata: MEmailMetadata = metadataList[0] as! MEmailMetadata
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (Int64)(1 * NSEC_PER_SEC)), queue, { () -> Void in
                        self.mailinator.getEmail(metadata.mid, completionHandler: { email, emailError in
                            if emailError != nil {
                                // We can't get the email and code.
                                if handler != nil {
                                    handler!(emailError!)
                                }
                                return
                            }
                            
                            // Extract the email body text
                            let bodyPart: MPart = email.parts[0] as! MPart
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
                            self.keysClient.persistUserDataId(ud.idb.userDataId, confirmationCode: code, completionHandler: { confirmError in
                                if confirmError != nil {
                                    if handler != nil {
                                        handler!(confirmError!)
                                    }
                                    return
                                }
                                let index = (pKey.userDataList as NSArray).indexOfObject(ud)
                                // Confirmation successful!
                                if index != NSNotFound {
                                    confirmationList[index] = true;
                                }
                                
                                // Check if all of the user data confirmed - call handler without error, signalling that all is OK.
                                if self.completedConfirmationList(confirmationList) {
                                    if handler != nil {
                                        handler!(nil)
                                    }
                                }
                            })
                        })
                    })
                })
            })
        }
    }
    
    func createPublicKeyWithUserDataList(list: NSArray, confirmUserDataWithHandler handler: ((NSError?)->Void)?) {
        self.createPublicKeyWithUserDataList(list, handler: { error in
            if error != nil {
                if handler != nil {
                    handler!(error!)
                }
                return
            }
            
            let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(UInt64(kEstimatedEmailReceivingTime) * NSEC_PER_SEC)), queue, { () -> Void in
                self.confirmUserDataOfPublicKey(self.publicKey, handler: { udError in
                    if udError != nil {
                        if handler != nil {
                            handler!(udError!)
                        }
                        return
                    }
                    
                    if handler != nil {
                        handler!(nil)
                    }
                })
            })
        })
    }

}
