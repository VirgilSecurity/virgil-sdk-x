//
//  SignInViewController.swift
//  VirgilFirebaseChat
//
//  Created by Pavel Gorb on 6/17/16.
//  Copyright © 2016 Virgil Security, Inc. All rights reserved.
//

import UIKit

class SignInViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet private var svScroll: UIScrollView!
    @IBOutlet private var vContent: UIView!
    
    @IBOutlet private var tfEmail: UITextField!
    @IBOutlet private var tfPassword: UITextField!
    @IBOutlet private var bChat: UIButton!
    
    private var client = VSSClient(applicationToken: Constants.Virgil.Token)
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    private func toggleUIAvailability() {
        dispatch_async(dispatch_get_main_queue()) { 
            self.tfEmail.enabled = !self.tfEmail.enabled
            self.tfPassword.enabled = !self.tfPassword.enabled
            self.bChat.enabled = !self.bChat.enabled
        }
    }
    
    private func toggleNetworkOperationStatus() {
        let application = UIApplication.sharedApplication()
        dispatch_async(dispatch_get_main_queue()) {
            application.isIgnoringInteractionEvents() ?
                application.endIgnoringInteractionEvents() :
                application.beginIgnoringInteractionEvents()
            
            application.networkActivityIndicatorVisible = !application.networkActivityIndicatorVisible
        }
    }
    
    private func searchForExistingCard(identity: String, password: String) {
        self.toggleUIAvailability()
        self.toggleNetworkOperationStatus()
        
        self.client.searchCardWithIdentityValue(self.tfEmail.text!, type: Constants.Virgil.FirebaseChatUser, unauthorized: false) { (cards, error) in
            if error != nil {
                /// In case of error check if there is no card found?
                if error!.code == kVSSKeysCardNotFoundError {
                    /// There is no such card on the service found.
                    /// Need to create new card.
                    self.createAndPublishNewCard(self.tfEmail.text!, password: self.tfPassword.text!)
                    return
                }
                /// Otherwise - there is an error searching for the card.
                print("Error getting cards: \(error!.localizedDescription)")
                self.toggleNetworkOperationStatus()
                self.toggleUIAvailability()
                dispatch_async(dispatch_get_main_queue()) {
                    self.tfPassword.text = ""
                }
                return
            }
            
            /// There should be only one card in response.
            if let candidates = cards where candidates.count > 0 {
                /// Store the Virgil Card received from the service.
                let card = candidates[0]
                AppState.sharedInstance.cards[card.identity.value] = card
                AppState.sharedInstance.identity = identity
                /// Get the private key from the keychain:
                let keyChainValue = VSSKeychainValue(id: Constants.Virgil.PrivateKeyStorage, accessGroup: nil)
                AppState.sharedInstance.privateKey = keyChainValue.objectForKey(card.identity.value) as? VSSPrivateKey
                /// Update the UI controls
                self.toggleUIAvailability()
                dispatch_async(dispatch_get_main_queue()) {
                    self.tfPassword.text = ""
                }
                self.toggleNetworkOperationStatus()
                /// Check if the private key is nil (there is no private key in the keychain)
                if AppState.sharedInstance.privateKey != nil {
                    self.navigateToChat()
                }
                else {
                    dispatch_async(dispatch_get_main_queue()) {
                        let alert = UIAlertController(title: "Ooops!", message: "There is no private key found for \(identity) on this device.", preferredStyle: .Alert)
                        let action = UIAlertAction(title: "Ok", style: .Cancel, handler: { (action) in
                            AppState.sharedInstance.kill()
                            alert.dismissViewControllerAnimated(true, completion: nil)
                        })
                        alert.addAction(action)
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                    return
                }
            }
            else {
                /// There is no cards returned - need to create one
                /// Need to create new card.
                self.createAndPublishNewCard(self.tfEmail.text!, password: self.tfPassword.text!)
            }
        }
    }
    
    private func createAndPublishNewCard(identity: String, password: String) {
        /// Generate the key pair:
        let keyPair = VSSKeyPair(password: password)
        /// Wrap the private key into the convenient wrapper object:
        AppState.sharedInstance.privateKey = VSSPrivateKey(key: keyPair.privateKey(), password: password)
        /// Compose the identity info object for the future Virgil Card:
        let identityInfo = VSSIdentityInfo(type: Constants.Virgil.FirebaseChatUser, value: identity)
        /// Wrap the application private key
        let applicationPrivateKey = VSSPrivateKey(key: Constants.Virgil.PrivateKey.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, password: Constants.Virgil.PrivateKeyPassword)
        /// Compose the validationToken for the identity (We are confirming that we are responsible for the identity)
        VSSValidationTokenGenerator.setValidationTokenForIdentityInfo(identityInfo, privateKey: applicationPrivateKey, error: nil)
        self.client.createCardWithPublicKey(keyPair.publicKey(), identityInfo: identityInfo, data: nil, privateKey: AppState.sharedInstance.privateKey) { (card, error) in
            if error != nil || card == nil {
                print("Error publishing the Virgil Card: \(error!.localizedDescription)")
                self.toggleNetworkOperationStatus()
                self.toggleUIAvailability()
                dispatch_async(dispatch_get_main_queue()) {
                    self.tfPassword.text = ""
                }
                return
            }
            
            /// Store the Virgil Card
            AppState.sharedInstance.cards[card!.identity.value] = card
            AppState.sharedInstance.identity = identity
            /// Store the private key
            let keyChainValue = VSSKeychainValue(id: Constants.Virgil.PrivateKeyStorage, accessGroup: nil)
            keyChainValue.setObject(AppState.sharedInstance.privateKey, forKey: card!.identity.value)
            /// Update UI Controls
            self.toggleUIAvailability()
            dispatch_async(dispatch_get_main_queue()) {
                self.tfPassword.text = ""
            }
            self.toggleNetworkOperationStatus()
            self.navigateToChat()
        }
    }
    
    private func navigateToChat() {
        dispatch_async(dispatch_get_main_queue()) { 
            self.performSegueWithIdentifier("ChatViewControllerSegue", sender: self)
        }
    }
    
    @IBAction func unwindToSignIn(segue: UIStoryboardSegue) {
    
    }
    
    @IBAction func chatAction(sender: AnyObject) {
        if self.tfEmail.text == nil || tfEmail.text!.isEmpty {
            self.tfEmail.becomeFirstResponder()
            return
        }
        
        if self.tfPassword.text == nil || self.tfPassword.text!.isEmpty {
            self.tfPassword.becomeFirstResponder()
            return
        }
        
        self.tfEmail.resignFirstResponder()
        self.tfPassword.resignFirstResponder()
        
        self.searchForExistingCard(self.tfEmail.text!, password: self.tfPassword.text!)
    }
    
}

extension SignInViewController {

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}

