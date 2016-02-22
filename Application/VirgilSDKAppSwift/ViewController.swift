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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        self.client = nil
        self.mailinator = nil
        self.publicKey = nil
        self.regexp = nil
    }

    

}

