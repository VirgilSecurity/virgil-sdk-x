//
//  Data+hex.swift
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 9/15/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

import Foundation

public extension Data {
    func hexEncodedString() -> String {
        return self
            .map({ String(format: "%02hhx", $0) })
            .joined()
    }

    init?(hexEncodedString hex: String) {
        let length = hex.lengthOfBytes(using: .ascii)

        guard length % 2 == 0 else {
            return nil
        }

        var data = Data()
        data.reserveCapacity(length / 2)

        var lowerBound = hex.startIndex

        while true {
            guard let upperBound = hex.index(lowerBound, offsetBy: 2, limitedBy: hex.endIndex) else {
                break
            }

            let c = hex.substring(with: Range(uncheckedBounds: (lowerBound, upperBound)))
            let res = strtol(c, nil, 16)
            data.append(contentsOf: [UInt8(res)])

            lowerBound = upperBound
        }

        self = data
    }
}
