//
//  RawSignedModel.swift
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 9/14/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

import Foundation

@objc(VSSRawSignedModel) public class RawSignedModel: NSObject, Serializable, Deserializable {
    @objc public let contentSnapshot: Data
    @objc public private(set) var signatures: [RawSignature]
    
    private enum CodingKeys: String, CodingKey {
        case contentSnapshot = "content_snapshot"
        case signatures
    }
    
    @objc public enum RawSignedModelError: Int, Error {
        case modelHasMaxSignatures
        case signatureWithThisIdExists
    }
    
    @objc public init(contentSnapshot: Data, signatures: [RawSignature]? = nil) {
        self.contentSnapshot = contentSnapshot
        self.signatures      = signatures ?? []
        
        super.init()
    }
    
    @objc public convenience init?(json: Any) {
        self.init(dict: json)
    }
    
    @objc public convenience init?(string: String) {
        self.init(base64: string)
    }
    
    @objc public func exportAsString() throws -> String {
        return try self.asStringBase64()
    }
    
    @objc public func exportAsJson() throws -> Any {
        return try self.asJson()
    }
    
    @objc public func addSignature(_ signature: RawSignature) throws {
        guard self.signatures.count < 8 else {
            throw RawSignedModelError.modelHasMaxSignatures
        }
        
        guard self.signatures.first(where: { $0.signerId == signature.signerId }) == nil else {
            throw RawSignedModelError.signatureWithThisIdExists
        }
        self.signatures.append(signature)
    }
}
