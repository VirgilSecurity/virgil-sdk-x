//
//  SnapshotUtils.swift
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 9/15/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

import Foundation

@objc public class SnapshotUtils: NSObject {
    public static func takeSnapshot(of object: Any) throws -> Data {
        return try JSONSerialization.data(withJSONObject: object, options: [])
    }

    public static func takeSnapshot(of object: Serializable) throws -> Data {
        return try object.asJsonData()
    }

    public static func parse<T: Deserializable>(_ snapshot: Data) -> T? {
        guard let json = try? JSONSerialization.jsonObject(with: snapshot, options: .allowFragments) else {
            return nil
        }

        return T(dict: json)
    }
}
