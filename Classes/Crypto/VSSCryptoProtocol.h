//
//  VSSCryptoProtocol.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 9/27/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VSSPrivateKey.h"
#import "VSSPublicKey.h"
#import "VSSKeyPair.h"
#import "VSSHashAlgorithm.h"
#import "VSSFingerprint.h"

@protocol VSSCrypto <NSObject>

- (VSSKeyPair * __nonnull)generateKeyPair;

- (VSSPrivateKey * __nullable)importPrivateKeyFromData:(NSData * __nonnull)data withPassword:(NSString * __nullable)password;
- (VSSPrivateKey * __nullable)importPrivateKeyFromData:(NSData * __nonnull)data;
- (VSSPublicKey * __nullable)importPublicKeyFromData:(NSData * __nonnull)data;
- (VSSPublicKey * __nonnull)extractPublicKeyFromPrivateKey:(VSSPrivateKey * __nonnull)privateKey NS_SWIFT_NAME(extractPublicKey(from:));

- (NSData * __nonnull)exportPrivateKey:(VSSPrivateKey * __nonnull)privateKey withPassword:(NSString * __nullable)password;
- (NSData * __nonnull)exportPublicKey:(VSSPublicKey * __nonnull)publicKey;

- (NSData * __nullable)encryptData:(NSData * __nonnull)data forRecipients:(NSArray<VSSPublicKey *> * __nonnull)recipients error:(NSError * __nullable * __nullable)errorPtr NS_SWIFT_NAME(encrypt(_:for:));
- (BOOL)encryptStream:(NSInputStream * __nonnull)stream toOutputStream:(NSOutputStream * __nonnull)outputStream forRecipients:(NSArray<VSSPublicKey *> * __nonnull)recipients error:(NSError * __nullable * __nullable)errorPtr NS_SWIFT_NAME(encrypt(_:to:for:));

    // verify is defined in <usr/include/AssertMacros.h> thus can't be used as base name in NS_SWIFT_NAME
- (BOOL)verifyData:(NSData * __nonnull)data withSignature:(NSData * __nonnull)signature usingSignerPublicKey:(VSSPublicKey * __nonnull)signerPublicKey error:(NSError * __nullable * __nullable)errorPtr NS_SWIFT_NAME(verifyData(_:with:using:));
- (BOOL)verifyStream:(NSInputStream * __nonnull)stream signature:(NSData * __nonnull)signature usingSignerPublicKey:(VSSPublicKey * __nonnull)signerPublicKey error:(NSError * __nullable * __nullable)errorPtr NS_SWIFT_NAME(verifyStream(_:with:using:));

- (NSData * __nullable)decryptData:(NSData * __nonnull)data withPrivateKey:(VSSPrivateKey * __nonnull)privateKey error:(NSError * __nullable * __nullable)errorPtr NS_SWIFT_NAME(decrypt(_:with:));
- (BOOL)decryptStream:(NSInputStream * __nonnull)stream toOutputStream:(NSOutputStream * __nonnull)outputStream withPrivateKey:(VSSPrivateKey * __nonnull)privateKey error:(NSError * __nullable * __nullable)errorPtr NS_SWIFT_NAME(decrypt(_:to:with:));

- (NSData * __nullable)signAndEncryptData:(NSData * __nonnull)data withPrivateKey:(VSSPrivateKey * __nonnull)privateKey forRecipients:(NSArray<VSSPublicKey *> * __nonnull)recipients error:(NSError * __nullable * __nullable)errorPtr NS_SWIFT_NAME(signAndEncrypt(_:with:for:));
- (NSData * __nullable)decryptAndVerifyData:(NSData * __nonnull)data withPrivateKey:(VSSPrivateKey * __nonnull)privateKey usingSignerPublicKey:(VSSPublicKey * __nonnull)signerPublicKey error:(NSError * __nullable * __nullable)errorPtr NS_SWIFT_NAME(decryptAndVerify(_:with:using:));

- (NSData * __nullable)generateSignatureForData:(NSData * __nonnull)data withPrivateKey:(VSSPrivateKey * __nonnull)privateKey error:(NSError * __nullable * __nullable)errorPtr;
- (NSData * __nullable)generateSignatureForStream:(NSInputStream * __nonnull)stream withPrivateKey:(VSSPrivateKey * __nonnull)privateKey error:(NSError * __nullable * __nullable)errorPtr;

- (VSSFingerprint * __nonnull)calculateFingerprintForData:(NSData * __nonnull)data;

- (NSData * __nonnull)computeHashForData:(NSData * __nonnull)data withAlgorithm:(VSSHashAlgorithm)algorithm;

@end
