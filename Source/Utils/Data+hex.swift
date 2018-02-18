//
//  Data+hex.swift
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 9/15/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

import Foundation

// MARK: - Data extension for hex encoding and decoding
public extension Data {
    /// Encodes data in hex format
    ///
    /// - Returns: Hex-encoded string
    func hexEncodedString() -> String {
        return self
            .map({ String(format: "%02hhx", $0) })
            .joined()
    }

    /// Initializer
    ///
    /// - Parameter hex: Hex-encoded string
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

            let c = String(hex[Range(uncheckedBounds: (lowerBound, upperBound))])
            let res = strtol(c, nil, 16)
            data.append(contentsOf: [UInt8(res)])

            lowerBound = upperBound
        }

        self = data
    }
}
