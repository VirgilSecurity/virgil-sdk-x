//
// Copyright (C) 2015-2019 Virgil Security Inc.
//
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are
// met:
//
//     (1) Redistributions of source code must retain the above copyright
//     notice, this list of conditions and the following disclaimer.
//
//     (2) Redistributions in binary form must reproduce the above copyright
//     notice, this list of conditions and the following disclaimer in
//     the documentation and/or other materials provided with the
//     distribution.
//
//     (3) Neither the name of the copyright holder nor the names of its
//     contributors may be used to endorse or promote products derived from
//     this software without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE AUTHOR ''AS IS'' AND ANY EXPRESS OR
// IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
// WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT,
// INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
// HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
// STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING
// IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.
//
// Lead Maintainer: Virgil Security Inc. <support@virgilsecurity.com>
//

import Foundation
import VirgilSDK
import VirgilCrypto

private class Config: NSObject, Decodable {
    let ServicePublicKey: String
    let ApiPrivateKey: String
    let AppId: String
    let ServiceURL: String?
    let CardId: String
    let CardIdentity: String
}
    
@objc public class TestUtils: NSObject {
    
    @objc public let crypto: VirgilCrypto
    private let config: Config
    
    private let apiKey: VirgilPrivateKey
    @objc public let servicePublicKey: VirgilPublicKey
    private let serviceURL: URL?
    
    private init(config: Config) {
        self.config = config
        let crypto = try! VirgilCrypto()
        self.crypto = crypto
        
        self.apiKey = try! crypto.importPrivateKey(from: Data(base64UrlEncoded: self.config.ApiPrivateKey)!).privateKey
        self.servicePublicKey = try! crypto.importPublicKey(from: Data(base64UrlEncoded: self.config.ServicePublicKey)!)
        
        if let urlStr = config.ServiceURL {
            self.serviceURL = URL(string: urlStr)!
        }
        else {
            self.serviceURL = nil
        }
        
        super.init()
    }
    
    @objc public static func readFromBundle() -> TestUtils {
        let bundle = Bundle(for: self)
        let configFileUrl = bundle.url(forResource: "TestConfig", withExtension: "plist")!
        let data = try! Data(contentsOf: configFileUrl)
        
        return TestUtils(config: try! PropertyListDecoder().decode(Config.self, from: data))
    }
    
    @objc public func getGeneratorJwtProvider(withIdentity identity: String) -> AccessTokenProvider {
        let generator = try! JwtGenerator(apiKey: self.apiKey, crypto: self.crypto, appId: self.config.AppId)
        
        return CachingJwtProvider(renewJwtCallback: { (_, completion) in
            do {
                completion(try generator.generateToken(identity: identity), nil)
            }
            catch {
                completion(nil, error)
            }
        })
    }
    
    @objc public func getRandomData() -> Data {
        return try! self.crypto.generateRandomData(ofSize: 1024)
    }
    
    @objc public func setupClient(withIdentity identity: String) -> CardClient {
        
        return CardClient(accessTokenProvider: self.getGeneratorJwtProvider(withIdentity: identity), serviceUrl: self.serviceURL ?? CardClient.defaultURL)
    }
}
