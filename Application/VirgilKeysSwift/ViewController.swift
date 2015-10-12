//
//  ViewController.swift
//  VirgilKeysSwift
//
//  Created by Pavel Gorb on 9/29/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var keysClient: VKKeysClientStg! = nil
    var mailinator: Mailinator! = nil
    var keyPair: VCKeyPair = VCKeyPair()
    var regexp: NSRegularExpression! = nil
    var publicKey: VKPublicKey! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let pubBase64 = self.keyPair.publicKey().base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
        print(pubBase64)
        let privBase64 = self.keyPair.privateKey().base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
        print(privBase64)
        
        self.keysClient = VKKeysClientStg(applicationToken: "e872d6f718a2dd0bd8cd7d7e73a25f49")
        self.mailinator = Mailinator(applicationToken: "3b0f46370d9f44cb9b5ac0e80dda97d7")
        do {
            self.regexp = try NSRegularExpression(pattern: "Your confirmation code is.+([A-Z0-9]{6})", options: NSRegularExpressionOptions.CaseInsensitive)
        }
        catch {
            self.regexp = nil
        }
        
        let userData = VKUserData(idb: VKIdBundle(), dataClass: .UDCUserId, dataType: .UDTEmail, value: "virgil.test.ios@mailinator.com", confirmed: false)
        self.createAndConfirmPublicKeyWithUserDataList(NSArray(array: [userData])) { error in
            if error != nil {
                print("Error confirmation of the user data: \(error!.localizedDescription)")
                return
            }
            
            print("Public key is created and confirmed!")
            print("Account ID: \(self.publicKey.idb.containerId)")
            print("Public key ID: \(self.publicKey.idb.publicKeyId)")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        self.keysClient = nil
        self.mailinator = nil
        self.publicKey = nil
        self.regexp = nil
    }

    func createPublicKeyWithUserDataList(list: NSArray, handler: ((NSError?) -> Void)?) {
        let privKey = VFPrivateKey(key: self.keyPair.privateKey(), password: nil)
        let pKey = VKPublicKey(idb: VKIdBundle(), key: self.keyPair.publicKey(), userDataList: list as [AnyObject])
        self.keysClient.createPublicKey(pKey, privateKey: privKey) { pubKey, error in
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
                            self.keysClient.persistUserDataId(ud.idb.userDataId!, confirmationCode: code, completionHandler: { confirmError in
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
    
    func createAndConfirmPublicKeyWithUserDataList(list: NSArray, confirmUserDataWithHandler handler: ((NSError?)->Void)?) {
        self.createPublicKeyWithUserDataList(list, handler: { error in
            if error != nil {
                if handler != nil {
                    handler!(error!)
                }
                return
            }
            
            let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(UInt64(2) * NSEC_PER_SEC)), queue, { () -> Void in
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
    
    func completedConfirmationList(list: NSArray) -> Bool {
        for conf in list {
            if !(conf as! NSNumber).boolValue {
                return false
            }
        }
        
        return true
    }

}

