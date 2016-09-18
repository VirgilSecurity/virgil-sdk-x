//
//  ViewController.swift
//  VirgilSample
//
//  Created by Pavel Gorb on 6/15/16.
//  Copyright © 2016 Virgil Security, Inc. All rights reserved.
//

import UIKit

/// This token should be generated on the https://developer.virgilsecurity.com/dashboard/
let kVirgilApplicationToken: String = "eyJpZCI6IjhlZGE3NWRjLTYwZGItNGQwZC1iOTc2LTBhZWMyYWNkZWVjNSIsImFwcGxpY2F0aW9uX2NhcmRfaWQiOiI1YWQ0YzE1Ny02MDMwLTRlYjAtOWUwNC1hN2JjY2ZhMTZkYWUiLCJ0dGwiOi0xLCJjdGwiOi0xLCJwcm9sb25nIjowfQ==.MFkwDQYJYIZIAWUDBAICBQAESDBGAiEA7aa4wvUgAOaVicAvumRKgJRyvxx/fNWENVhi3q3p7+YCIQCF6x81cA++7q2MC+dvrNoZ+ATVXBtVk85LpIovL109HA=="
/// This is the application private key. It should be get from the https://developer.virgilsecurity.com/dashboard/
let kVirgilApplicationPrivateKey: String = "-----BEGIN ENCRYPTED PRIVATE KEY-----\nMIHyMF0GCSqGSIb3DQEFDTBQMC8GCSqGSIb3DQEFDDAiBBD5qeF0P2hTWT89ESlp\n/EF4AgIaPjAKBggqhkiG9w0CCjAdBglghkgBZQMEASoEEMINi5oE24r/uki0HJTc\nR+wEgZDVFEGsl7VsADI1laExBxBco3EDuwsadSjyeGyVIqlJMnJrROxbEqCbkeNo\nDPtcQhS6LxA/C5dcyzGwMd1KAWzNHi8tjZdI1GnJEz6XrAbZM0Y8ZCiKY5sE74G6\neBPSJX/F2fJV4+QkFgYOPBXIIUnOzmXHERYGsN9LL852edX/Fkt+G8GwaA3IrJMl\npy1OgB0=\n-----END ENCRYPTED PRIVATE KEY-----\n"
/// Just sample type for the user identity.
let kSampleIdentityType: String = "Sample"
/// Const key for the KeyChain to store private keys for this app.
let kPrivateKeyStorage: String = "PrivateKeyStorage"

class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet private var lUser: UILabel!
    @IBOutlet private var lUserValue: UILabel!
    @IBOutlet private var tfUserValue: UITextField!
    @IBOutlet private var bGetKey: UIButton!
    @IBOutlet private var tfMessage: UITextField!
    @IBOutlet private var lEncryptedMessage: UILabel!
    @IBOutlet private var bEncrypt: UIButton!
    
    /// Virgil Services client
    private let virgilClient = VSSClient(applicationToken: kVirgilApplicationToken)
    /// Virgil Card for the current user.
    private var card: VSSCard! = nil
    /// Private key of the current user.
    private var privateKey: VSSPrivateKey! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tfMessage.enabled = false
        self.lEncryptedMessage.enabled = false
        self.bEncrypt.enabled = false
    }
    
    /**
     * Function which initiates search for an existing card on the Virgil Serivce.
     * If the card is found - saves it in a property, restores the private key from the keychain
     * and updates the UI.
     * If there is no card found - initiates routine to create and publish new one.
     * 
     * @param identity String containing user identity value (e.g. email address)
     */
    private func searchVirgilCard(identity: String) {
        /// Initiate the service request to search Virgil Card.
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        self.virgilClient.searchCardWithIdentityValue(identity, type: kSampleIdentityType, unauthorized: false) { (cards, error) in
            if error != nil  {
                /// In case of error check if there is no card found?
                if error!.code == kVSSKeysCardNotFoundError {
                    /// There is no such card on the service found.
                    /// Need to create new card.
                    self.publishVirgilCard(identity)
                    return
                }
                /// Otherwise - there is an error searching for the card.
                print("Error getting cards: \(error!.localizedDescription)")
                dispatch_async(dispatch_get_main_queue(), {
                    UIApplication.sharedApplication().endIgnoringInteractionEvents()
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                })
                return
            }
            
            /// There should be only one card in response.
            /// Anyway, we now get the first card from the response.
            if let candidates = cards where candidates.count > 0 {
                /// Store the Virgil Card received from the service.
                self.card = candidates[0]
                /// Get the private key from the keychain:
                let keyChainValue = VSSKeychainValue(id: kPrivateKeyStorage, accessGroup: nil)
                self.privateKey = keyChainValue.objectForKey(self.card.identity.value) as? VSSPrivateKey
                /// Update the UI controls
                dispatch_async(dispatch_get_main_queue(), {
                    UIApplication.sharedApplication().endIgnoringInteractionEvents()
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                })
                dispatch_async(dispatch_get_main_queue(), {
                    /// Show the identity on the label
                    self.lUserValue.text = self.card.identity.value
                    /// Clear the text field.
                    self.tfUserValue.text = ""
                    self.tfUserValue.enabled = false
                    /// Disable the button 'Get My Key'
                    self.bGetKey.enabled = false
                    /// Enable components for Encrypting message
                    self.tfMessage.enabled = true
                    self.lEncryptedMessage.enabled = true
                    self.bEncrypt.enabled = true
                })
            }
            else {
                /// There is no cards returned - need to create one
                /// Need to create new card.
                self.publishVirgilCard(identity)
            }
        }
    }
    
    /**
     * Function which creates a new Virgil Card and publishes it on the Virgil Service.
     * 
     * @param identity String containing user identity value (e.g. email address)
     */
    private func publishVirgilCard(identity: String) {
        /// Generate the key pair:
        let keyPair = VSSKeyPair(password: "secret")
        /// Wrap the private key into the convenient wrapper object:
        self.privateKey = VSSPrivateKey(key: keyPair.privateKey(), password: "secret")
        /// Compose the identity info object for the future Virgil Card:
        let identityInfo = VSSIdentityInfo(type: kSampleIdentityType, value: identity)
        /// Wrap the application private key 
        let applicationPrivateKey = VSSPrivateKey(key: kVirgilApplicationPrivateKey.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, password: "1231")
        /// Compose the validationToken for the identity (We are confirming that we are responsible for the identity)
        VSSValidationTokenGenerator.setValidationTokenForIdentityInfo(identityInfo, privateKey: applicationPrivateKey, error: nil)
        self.virgilClient.createCardWithPublicKey(keyPair.publicKey(), identityInfo: identityInfo, data: nil, privateKey: self.privateKey) { (card, error) in
            if error != nil {
                dispatch_async(dispatch_get_main_queue(), {
                    UIApplication.sharedApplication().endIgnoringInteractionEvents()
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                })
                print("Error publishing the Virgil Card: \(error!.localizedDescription)")
                return
            }
            
            /// Store the Virgil Card
            self.card = card
            /// Store the private key
            let keyChainValue = VSSKeychainValue(id: kPrivateKeyStorage, accessGroup: nil)
            keyChainValue.setObject(self.privateKey, forKey: self.card.identity.value)
            /// Update UI Controls
            dispatch_async(dispatch_get_main_queue(), {
                UIApplication.sharedApplication().endIgnoringInteractionEvents()
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            })
            dispatch_async(dispatch_get_main_queue(), {
                /// Show the identity on the label
                self.lUserValue.text = self.card.identity.value
                /// Clear the text field.
                self.tfUserValue.text = ""
                self.tfUserValue.enabled = false
                /// Disable the button 'Get My Key'
                self.bGetKey.enabled = false
                /// Enable components for Encrypting message
                self.tfMessage.enabled = true
                self.lEncryptedMessage.enabled = true
                self.bEncrypt.enabled = true
            })
        }
    }
    
    /**
     * Action handler for 'Get my key' action. Initiates search for the VirgilCard on the Service.
     */
    @IBAction func getKeyAction(sender: AnyObject) {
        /// Initiate routine for searching an existing card first:
        self.searchVirgilCard(self.tfUserValue.text!)
    }
    
    /**
     * Performs the encryption for the plain text message entered by the user, 
     * after 'Encrypt' button has been pressed.
     */
    @IBAction func encryptAction(sender: AnyObject) {
        var encrytedData = NSData()
        if let plainData = self.tfMessage.text?.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
            let cryptor = VSSCryptor()
            do {
                try cryptor.addKeyRecipient(self.card.Id, publicKey: self.card.publicKey.key, error: ())
                encrytedData = try cryptor.encryptData(plainData, embedContentInfo: true, error: ())
                /// Update UI Controls
                self.lEncryptedMessage.text = encrytedData.base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
            }
            catch let error as NSError {
                print("Encryption error: \(error.localizedDescription)")
            }
        }
    }

}

extension ViewController {

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}

