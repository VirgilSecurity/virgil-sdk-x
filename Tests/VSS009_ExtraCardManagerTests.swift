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

class CardClientStub_STC3: CardClient {
    private var testsDict: Dictionary<String, Any>!

    init() {
        let testFileURL = Bundle(for: type(of: self)).url(forResource: "test_data", withExtension: "txt")!
        let testFileData = try! Data(contentsOf: testFileURL)
        self.testsDict = try! JSONSerialization.jsonObject(with: testFileData, options: JSONSerialization.ReadingOptions.init(rawValue: 0)) as! Dictionary<String, Any>

        super.init(connection: ServiceConnection())
    }

    @objc override func getCard(withId cardId: String, token: String, completion: (RawSignedModel, Bool) -> ()) throws {
        let response = RawSignedModel.importFrom(base64Encoded: self.testsDict["STC-3.as_string"] as! String)

        completion(response!, false)
    }

    @objc override func publishCard(model: RawSignedModel, token: String) throws -> RawSignedModel {
        return RawSignedModel.importFrom(base64Encoded: self.testsDict["STC-3.as_string"] as! String)!
    }


    @objc override func searchCards(identity: String, token: String) throws -> [RawSignedModel] {
        return [RawSignedModel.importFrom(base64Encoded: self.testsDict["STC-3.as_string"] as! String)!]
    }
}

class CardClientStub_STC34: CardClient {
    private var testsDict: Dictionary<String, Any>!

    init() {
        let testFileURL = Bundle(for: type(of: self)).url(forResource: "test_data", withExtension: "txt")!
        let testFileData = try! Data(contentsOf: testFileURL)
        self.testsDict = try! JSONSerialization.jsonObject(with: testFileData, options: JSONSerialization.ReadingOptions.init(rawValue: 0)) as! Dictionary<String, Any>

        super.init(connection: ServiceConnection())
    }

    @objc override func getCard(withId cardId: String, token: String, completion: (RawSignedModel, Bool) -> ()) throws {
        let response = RawSignedModel.importFrom(base64Encoded: self.testsDict["STC-34.as_string"] as! String)

        completion(response!, false)
    }

    @objc override func publishCard(model: RawSignedModel, token: String) throws -> RawSignedModel {
        return RawSignedModel.importFrom(base64Encoded: self.testsDict["STC-34.as_string"] as! String)!
    }


    @objc override func searchCards(identity: String, token: String) throws -> [RawSignedModel] {
        return [RawSignedModel.importFrom(base64Encoded: self.testsDict["STC-34.as_string"] as! String)!]
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

        let testFileURL = Bundle(for: type(of: self)).url(forResource: "test_data", withExtension: "txt")!
        let testFileData = try! Data(contentsOf: testFileURL)
        self.testsDict = try! JSONSerialization.jsonObject(with: testFileData, options: JSONSerialization.ReadingOptions.init(rawValue: 0)) as! Dictionary<String, Any>

        self.crypto = VirgilCrypto()
        self.consts = VSSTestsConst()
        self.utils = VSSTestUtils.init(crypto: self.crypto, consts: self.consts)
        self.cardCrypto = VirgilCardCrypto(virgilCrypto: self.crypto)
        self.modelSigner = ModelSigner(crypto: self.cardCrypto)
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
        let cardManager = CardManager(crypto: self.cardCrypto, accessTokenProvider: generator,
                                           modelSigner: self.modelSigner, cardClient: CardClientStub_STC3(),
                                           cardVerifier: VerifierStubFalse(), signCallback: nil)
        var errorWasThrows = false
        do {
          _ = try cardManager.importCard(string: self.testsDict["STC-3.as_string"] as! String)
        } catch {
            errorWasThrows = true
        }

        XCTAssert(errorWasThrows)
        errorWasThrows = false

        do {
            let data = (self.testsDict["STC-3.as_json"] as! String).data(using: .utf8)!
            let dic = try JSONSerialization.jsonObject(with: data, options: [])
            _ = try  cardManager.importCard(json: dic)
        } catch {
            errorWasThrows = true
        }
        XCTAssert(errorWasThrows)
        errorWasThrows = false

        let keyPair = try! self.crypto.generateKeyPair()
        let operation1 = try! cardManager.publishCard(privateKey: keyPair.privateKey, publicKey: keyPair.publicKey, identity: nil)
        let result1 = operation1.startSync()
        switch result1 {
        case .success: break
        case .failure:
            errorWasThrows = true
        }

        XCTAssert(errorWasThrows)
        errorWasThrows = false

        let rawCard = RawSignedModel.importFrom(base64Encoded: self.testsDict["STC-3.as_string"] as! String)!
        let operation2 = cardManager.publishCard(rawCard: rawCard)
        let result2 = operation2.startSync()

        switch result2 {
        case .success: break
        case .failure:
            errorWasThrows = true
        }
        XCTAssert(errorWasThrows)
        errorWasThrows = false

        let operation3 = cardManager.getCard(withId: "some_id")
        let result3 = operation3.startSync()

        switch result3 {
        case .success: break
        case .failure:
            errorWasThrows = true
        }
        XCTAssert(errorWasThrows)
        errorWasThrows = false

        let operation4 = cardManager.searchCards(identity: "some_identity")
        let result4 = operation4.startSync()

        switch result4 {
        case .success: break
        case .failure:
            errorWasThrows = true
        }
        XCTAssert(errorWasThrows)
    }

    func test002_STC_34() {
        let generator = self.utils.getGeneratorJwtProvider(withIdentity: "identity", error: nil)
        let cardManager = CardManager(crypto: self.cardCrypto, accessTokenProvider: generator,
                                           modelSigner: self.modelSigner, cardClient: CardClientStub_STC34(),
                                           cardVerifier: VerifierStubTrue(), signCallback: nil)
        let operation = cardManager.getCard(withId: "375f795bf6799b18c4836d33dce5208daf0895a3f7aacbcd0366529aed2345d4")
        let result = operation.startSync()

        var errorWasThrows = false

        switch result {
        case .success: break
        case .failure:
            errorWasThrows = true
        }
        XCTAssert(errorWasThrows)
    }

    func test003_STC_35() {
        let generator = self.utils.getGeneratorJwtProvider(withIdentity: "identity", error: nil)
        let cardManager = CardManager(crypto: self.cardCrypto, accessTokenProvider: generator,
                                      modelSigner: self.modelSigner, cardClient: CardClientStub_STC34(),
                                      cardVerifier: VerifierStubTrue(), signCallback: nil)

        let publicKeyBase64 = self.testsDict["STC-34.public_key_base64"] as! String

        let cardContent = RawCardContent(identity: "some identity", publicKey: publicKeyBase64, createdAt: Date())
        let snapshot = try! JSONEncoder().encode(cardContent)
        let rawCard1 = RawSignedModel(contentSnapshot: snapshot)

        let privateKeyBase64 = self.testsDict["STC-34.private_key_base64"] as! String
        let exporter = VirgilPrivateKeyExporter(virgilCrypto: self.crypto, password: nil)
        let privateKey = try! exporter.importPrivateKey(from: Data(base64Encoded: privateKeyBase64)!)
        let extraDataSnapshot = self.testsDict["STC-34.self_signature_snapshot_base64"] as! String
        try! self.modelSigner.selfSign(model: rawCard1, privateKey: privateKey, additionalData: Data(base64Encoded: extraDataSnapshot))

        let operation1 = cardManager.publishCard(rawCard: rawCard1)
        let result1 = operation1.startSync()

        var errorWasThrows = false
        switch result1 {
        case .success: break
        case .failure:
            errorWasThrows = true
        }
        XCTAssert(errorWasThrows)
        errorWasThrows = false

        let contentStnapshot = testsDict["STC-34.content_snapshot_base64"] as! String
        let rawCard2 = RawSignedModel(contentSnapshot: Data(base64Encoded: contentStnapshot)!)

        let operation2 = cardManager.publishCard(rawCard: rawCard2)
        let result2 = operation2.startSync()

        switch result2 {
        case .success: break
        case .failure:
            errorWasThrows = true
        }
        XCTAssert(errorWasThrows)
    }
}
