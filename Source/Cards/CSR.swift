//
//  CSR.swift
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 9/15/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

import Foundation
import VirgilCryptoAPI

@objc(VSSCSR) public class CSR: NSObject {
    private let info: RawCardInfo
    private let snapshot: Data
    private var signatures: [CardSignature] = []
    
    private init(info: RawCardInfo, snapshot: Data, cardId: String) {
        self.info = info
        self.snapshot = snapshot
        self.cardId = cardId
        
        super.init()
    }
    
    public let cardId: String
    public var identity: String { return self.info.identity }
    public var publicKeyData: Data { return self.info.publicKeyData }
    public var version: String { return self.info.version }
    public var createdAt: Date { return self.info.createdAt }
    
    public var rawCard: RawCard {
        return RawCard(contentSnapshot: self.snapshot, signatures: self.signatures)
    }
    
    public func sign(crypto: Crypto, params: SignParams) throws {
        // FIXME
        guard params.signerType != .self || self.signatures.first(where: { $0.signerType == .self }) == nil else {
            throw NSError()
        }
        
        guard params.signerType != .application || self.signatures.first(where: { $0.signerType == .application }) == nil else {
            throw NSError()
        }
        
        let extraData: Data
        let fingerprintPayload: Data
        
        if let extraFields = params.extraFields, params.signerType != .self {
            extraData = try SnapshotUtils.takeSnapshot(object: extraFields)
            fingerprintPayload = self.snapshot + extraData
        }
        else {
            extraData = Data()
            fingerprintPayload = self.snapshot
        }
        
        let fingerprint = crypto.computeSHA256(for: fingerprintPayload)
        let signature = try crypto.generateSignature(of: fingerprint, using: params.signerPrivateKey)
        
        let cardSignature = CardSignature(signerId: params.signerCardId, signerType: params.signerType, signature: signature, extraData: extraData)
        
        self.signatures.append(cardSignature)
    }
    
    public func export() throws -> String {
        let rawCard = RawCard(contentSnapshot: self.snapshot, signatures: self.signatures)
        
        let json = rawCard.serialize()
        let jsonData = try JSONSerialization.data(withJSONObject: json, options: [])
        
        return jsonData.base64EncodedString()
    }
    
    public func `import`(crypto: Crypto, csr: String) throws -> CSR {
        guard let data = Data(base64Encoded: csr) else {
            throw NSError()
        }
        
        let json = try JSONSerialization.jsonObject(with: data, options: [])
        
        guard let rawCard = RawCard(dict: json) else {
            throw NSError()
        }
        
        guard let snapshotData = Data(base64Encoded: rawCard.contentSnapshot) else {
            throw NSError()
        }
        
        let snapshotJson = try JSONSerialization.jsonObject(with: snapshotData, options: [])
        
        guard let rawCardInfo = RawCardInfo(dict: snapshotJson) else {
            throw NSError()
        }
        
        let fingerprint = crypto.computeSHA256(for: rawCard.contentSnapshot)
        let cardId = fingerprint.hexEncodedString()
        

        return CSR(info: rawCardInfo, snapshot: rawCard.contentSnapshot, cardId: cardId)
    }
    
    public static let CurrentCardVersion = "5.0"
    public class func generate(crypto: Crypto, params: CSRParams) throws -> CSR {
        let cardInfo = RawCardInfo(identity: params.identity, publicKeyData: try crypto.exportPublicKey(params.publicKey), version: CSR.CurrentCardVersion, createdAt: Date())
        let snapshot = try SnapshotUtils.takeSnapshot(object: cardInfo)
        
        let cardId = crypto
            .computeSHA256(for: snapshot)
            .hexEncodedString()
        
        let csr = CSR(info: cardInfo, snapshot: snapshot, cardId: cardId)
        
        if let privateKey = params.privateKey {
            try csr.sign(crypto: crypto, params: SignParams(signerCardId: cardId, signerPrivateKey: privateKey, signerType: .self))
        }
        
        return csr
    }
}
