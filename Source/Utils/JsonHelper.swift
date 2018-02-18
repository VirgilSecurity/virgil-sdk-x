//
//  JsonHelper.swift
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 2/16/18.
//  Copyright © 2018 VirgilSecurity. All rights reserved.
//

import Foundation

internal final class JsonHelper {
    internal static func timestampDateDecodingStrategy(decoder: Decoder) throws -> Date {
        let timestamp = try decoder.singleValueContainer().decode(Int.self)

        return Date(timeIntervalSince1970: TimeInterval(timestamp))
    }

    internal static func timestampDateEncodingStrategy(date: Date, encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(Int(date.timeIntervalSince1970))
    }
}
