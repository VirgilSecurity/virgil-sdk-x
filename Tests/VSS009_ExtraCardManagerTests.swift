//
//  VSS009_ExtraCardManagerTests.swift
//  VirgilSDK
//
//  Created by Eugen Pivovarov on 2/12/18.
//  Copyright © 2018 VirgilSecurity. All rights reserved.
//

import Foundation

import VirgilCrypto
import XCTest
import VirgilCryptoApiImpl
import VirgilSDK

class CardClientStub_STC3: CardClientProtocol {
    private var testsDict: Dictionary<String, Any>!

    init() {
        let testFileURL = Bundle(for: type(of: self)).url(forResource: "data", withExtension: "json")!
        let testFileData = try! Data(contentsOf: testFileURL)
        self.testsDict = try! JSONSerialization.jsonObject(with: testFileData, options: JSONSerialization.ReadingOptions.init(rawValue: 0)) as! Dictionary<String, Any>
    }

    @objc func getCard(withId cardId: String, token: String) throws -> GetCardResponse {
        let response = try RawSignedModel.import(fromBase64Encoded: self.testsDict["STC-3.as_string"] as! String)

        return GetCardResponse(rawCard: response, isOutdated: false)
    }

    @objc func publishCard(model: RawSignedModel, token: String) throws -> RawSignedModel {
        return try RawSignedModel.import(fromBase64Encoded: self.testsDict["STC-3.as_string"] as! String)
    }

    @objc func searchCards(identity: String, token: String) throws -> [RawSignedModel] {
        return [try RawSignedModel.import(fromBase64Encoded: self.testsDict["STC-3.as_string"] as! String)]
    }
}

class CardClientStub_STC34: CardClientProtocol {
    private var testsDict: Dictionary<String, Any>!

    init() {
        let testFileURL = Bundle(for: type(of: self)).url(forResource: "data", withExtension: "json")!
        let testFileData = try! Data(contentsOf: testFileURL)
        self.testsDict = try! JSONSerialization.jsonObject(with: testFileData, options: JSONSerialization.ReadingOptions.init(rawValue: 0)) as! Dictionary<String, Any>
    }

    @objc func getCard(withId cardId: String, token: String) throws -> GetCardResponse {
        let response = try RawSignedModel.import(fromBase64Encoded: self.testsDict["STC-3.as_string"] as! String)
        
        return GetCardResponse(rawCard: response, isOutdated: false)
    }

    @objc func publishCard(model: RawSignedModel, token: String) throws -> RawSignedModel {
        return try RawSignedModel.import(fromBase64Encoded: self.testsDict["STC-34.as_string"] as! String)
    }

    @objc func searchCards(identity: String, token: String) throws -> [RawSignedModel] {
        return [try RawSignedModel.import(fromBase64Encoded: self.testsDict["STC-34.as_string"] as! String)]
    }
}

class VerifierStubFalse: CardVerifier {
    func verifyCard(card: Card) -> Bool {
        return false
    }
}

class VerifierStubTrue: CardVerifier {
    func verifyCard(card: Card) -> Bool {
        return true
    }
}

class VSS009_ExtraCardManagerTests: XCTestCase {
    private var crypto: VirgilCrypto!
    private var consts: VSSTestsConst!
    private var cardCrypto: VirgilCardCrypto!
    private var utils: VSSTestUtils!
    private var modelSigner: ModelSigner!
    private var testsDict: Dictionary<String, Any>!

    // MARK: Setup
    override func setUp() {
        super.setUp()

        let testFileURL = Bundle(for: type(of: self)).url(forResource: "data", withExtension: "json")!
        let testFileData = try! Data(contentsOf: testFileURL)
        self.testsDict = try! JSONSerialization.jsonObject(with: testFileData, options: JSONSerialization.ReadingOptions.init(rawValue: 0)) as! Dictionary<String, Any>

        self.crypto = VirgilCrypto()
        self.consts = VSSTestsConst()
        self.utils = VSSTestUtils(crypto: self.crypto, consts: self.consts)
        self.cardCrypto = VirgilCardCrypto(virgilCrypto: self.crypto)
        self.modelSigner = ModelSigner(cardCrypto: self.cardCrypto)
    }

    override func tearDown() {
        self.crypto = nil
        self.consts = nil
        self.cardCrypto = nil
        self.modelSigner = nil
        
        super.tearDown()
    }

    // MARK: Tests
    func test001_STC_13() {
        let generator = self.utils.getGeneratorJwtProvider(withIdentity: "identity", error: nil)
        
        let cardManagerParams = CardManagerParams(cardCrypto: self.cardCrypto, accessTokenProvider: generator, cardVerifier: VerifierStubFalse())
        cardManagerParams.cardClient = CardClientStub_STC3()
        
        let cardManager = CardManager(params: cardManagerParams)
        
        var errorWasThrown = false
        do {
          _ = try cardManager.importCard(fromBase64Encoded: self.testsDict["STC-3.as_string"] as! String)
        } catch {
            errorWasThrown = true
        }

        XCTAssert(errorWasThrown)
        errorWasThrown = false

        do {
            let data = (self.testsDict["STC-3.as_json"] as! String).data(using: .utf8)!
            let dic = try JSONSerialization.jsonObject(with: data, options: [])
            _ = try  cardManager.importCard(fromJson: dic)
        } catch {
            errorWasThrown = true
        }
        XCTAssert(errorWasThrown)
        errorWasThrown = false

        let keyPair = try! self.crypto.generateKeyPair()
        let operation1 = try! cardManager.publishCard(privateKey: keyPair.privateKey, publicKey: keyPair.publicKey, identity: nil)

        switch operation1.startSync() {
        case .success: XCTFail()
        case .failure: break
        }

        let rawCard = try! RawSignedModel.import(fromBase64Encoded: self.testsDict["STC-3.as_string"] as! String)
        let operation2 = cardManager.publishCard(rawCard: rawCard)

        switch operation2.startSync() {
        case .success: XCTFail()
        case .failure: break
        }

        let operation3 = cardManager.getCard(withId: "some_id")

        switch operation3.startSync() {
        case .success: XCTFail()
        case .failure: break
        }

        let operation4 = cardManager.searchCards(identity: "some_identity")

        switch operation4.startSync() {
        case .success: XCTFail()
        case .failure: break
        }
    }

    func test002_STC_34() {
        let generator = self.utils.getGeneratorJwtProvider(withIdentity: "identity", error: nil)
        
        let cardManagerParams = CardManagerParams(cardCrypto: self.cardCrypto, accessTokenProvider: generator, cardVerifier: VerifierStubTrue())
        cardManagerParams.cardClient = CardClientStub_STC34()
        
        let cardManager = CardManager(params: cardManagerParams)
        
        switch cardManager.getCard(withId: "375f795bf6799b18c4836d33dce5208daf0895a3f7aacbcd0366529aed2345d4").startSync() {
        case .success: XCTFail()
        case .failure: break
        }
    }

    func test003_STC_35() {
        let generator = self.utils.getGeneratorJwtProvider(withIdentity: "identity", error: nil)
        
        let cardManagerParams = CardManagerParams(cardCrypto: self.cardCrypto, accessTokenProvider: generator, cardVerifier: VerifierStubTrue())
        cardManagerParams.cardClient = CardClientStub_STC34()
        
        let cardManager = CardManager(params: cardManagerParams)

        let publicKeyBase64 = self.testsDict["STC-34.public_key_base64"] as! String
        let publicKeyData = Data(base64Encoded: publicKeyBase64)!

        let cardContent = RawCardContent(identity: "some identity", publicKey: publicKeyData, createdAt: Date())
        let snapshot = try! JSONEncoder().encode(cardContent)
        let rawCard1 = RawSignedModel(contentSnapshot: snapshot)

        let privateKeyBase64 = self.testsDict["STC-34.private_key_base64"] as! String
        let exporter = VirgilPrivateKeyExporter(virgilCrypto: self.crypto, password: nil)
        let privateKey = try! exporter.importPrivateKey(from: Data(base64Encoded: privateKeyBase64)!)
        let extraDataSnapshot = self.testsDict["STC-34.self_signature_snapshot_base64"] as! String
        try! self.modelSigner.selfSign(model: rawCard1, privateKey: privateKey, additionalData: Data(base64Encoded: extraDataSnapshot)!)

        switch cardManager.publishCard(rawCard: rawCard1).startSync() {
        case .success: XCTFail()
        case .failure: break
        }

        let contentStnapshot = testsDict["STC-34.content_snapshot_base64"] as! String
        let rawCard2 = RawSignedModel(contentSnapshot: Data(base64Encoded: contentStnapshot)!)

        switch cardManager.publishCard(rawCard: rawCard2).startSync() {
        case .success: XCTFail()
        case .failure: break
        }
    }
    
    func test004_STC_36() {
        let generator = self.utils.getGeneratorJwtProvider(withIdentity: "identity", error: nil)
        
        let cardManagerParams = CardManagerParams(cardCrypto: self.cardCrypto, accessTokenProvider: generator, cardVerifier: VerifierStubTrue())
        cardManagerParams.cardClient = CardClientStub_STC34()
        
        let cardManager = CardManager(params: cardManagerParams)
        
        switch cardManager.searchCards(identity: "Alice").startSync() {
        case .success(_): XCTFail()
        case .failure(_): break
        }
    }
}
