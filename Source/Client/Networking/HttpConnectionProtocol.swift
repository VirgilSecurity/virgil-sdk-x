//
//  HttpConnectionProtocol.swift
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 9/14/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

import Foundation

public protocol HttpConnectionProtocol: class {
    func send(_ request: Request) throws -> Response
}
