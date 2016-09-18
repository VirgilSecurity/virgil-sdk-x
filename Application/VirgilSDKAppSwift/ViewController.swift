//
//  ViewController.swift
//  VirgilKeysSwift
//
//  Created by Pavel Gorb on 9/29/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var keyPair: VSSKeyPair = VSSKeyPair()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let pubBase64 = self.keyPair.publicKey().base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
        print(pubBase64)
        let privBase64 = self.keyPair.privateKey().base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
        print(privBase64)
    }
    
}

