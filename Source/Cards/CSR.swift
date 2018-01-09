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
    
    @objc public let cardId: String
    @objc public var identity: String { return self.info.identity }
    @objc public var publicKeyData: Data { return self.info.publicKeyData }
    @objc public var version: String { return self.info.version }
    @objc public var createdAt: Date { return self.info.createdAt }
    
    @objc public var rawCard: RawCard {
        return RawCard(contentSnapshot: self.snapshot, signatures: self.signatures)
    }
    
    @objc public func sign(crypto: CardCrypto, params: SignParams) throws {
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
    
    @objc public func export() throws -> String {
        let rawCard = RawCard(contentSnapshot: self.snapshot, signatures: self.signatures)
        
        let json = rawCard.serialize()
        let jsonData = try JSONSerialization.data(withJSONObject: json, options: [])
        
        return jsonData.base64EncodedString()
    }
    
    @objc public func `import`(crypto: CardCrypto, csr: String) throws -> CSR {
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
    
    @objc public static let CurrentCardVersion = "5.0"
    @objc public class func generate(crypto: CardCrypto, params: CSRParams) throws -> CSR {
        let cardInfo = RawCardInfo(identity: params.identity, publicKeyData: try crypto.exportPublicKey(params.publicKey), previousCardId: nil, version: CSR.CurrentCardVersion, createdAt: Date())
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
