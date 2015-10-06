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
    var keyPair: VCKeyPair = VCKeyPair()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let pubBase64 = keyPair.publicKey().base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
        print(pubBase64)
        let privBase64 = keyPair.privateKey().base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
        print(privBase64)
        
        self.keysClient = VKKeysClientStg(applicationToken: "e872d6f718a2dd0bd8cd7d7e73a25f49")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        self.keysClient = nil
    }


}

