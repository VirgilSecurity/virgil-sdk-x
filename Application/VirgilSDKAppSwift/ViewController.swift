//
//  ViewController.swift
//  VirgilKeysSwift
//
//  Created by Pavel Gorb on 9/29/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var mailinator: Mailinator! = nil
    var keyPair: VSSKeyPair = VSSKeyPair()
    var regexp: NSRegularExpression! = nil
    var publicKey: VSSPublicKey! = nil
    var client: VSSClient! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let pubBase64 = self.keyPair.publicKey().base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
        print(pubBase64)
        let privBase64 = self.keyPair.privateKey().base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
        print(privBase64)
        
//        self.client = VSSClient(applicationToken: "e872d6f718a2dd0bd8cd7d7e73a25f49", serviceConfig: VSSServiceConfigStg())
//        self.mailinator = Mailinator(applicationToken: "3b0f46370d9f44cb9b5ac0e80dda97d7")
//        do {
//            self.regexp = try NSRegularExpression(pattern: "Your confirmation code is.+([A-Z0-9]{6})", options: NSRegularExpressionOptions.CaseInsensitive)
//        }
//        catch {
//            self.regexp = nil
//        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        self.client = nil
        self.mailinator = nil
        self.publicKey = nil
        self.regexp = nil
    }

    

}

