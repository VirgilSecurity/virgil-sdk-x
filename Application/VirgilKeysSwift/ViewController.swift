//
//  ViewController.swift
//  VirgilKeysSwift
//
//  Created by Pavel Gorb on 9/29/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var keysClient: VKKeysClient!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.keysClient = VKKeysClient(applicationToken: "asdasdasdasdasd")
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

