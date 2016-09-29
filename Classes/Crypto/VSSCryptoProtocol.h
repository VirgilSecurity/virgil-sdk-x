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

@protocol VSSCrypto <NSObject>

- (VSSKeyPair * __nonnull)generateKey;

- (VSSPrivateKey * __nullable)importPrivateKey:(NSData * __nonnull)keyData password:(NSString * __nullable)password;
- (VSSPublicKey * __nullable)importPublicKey:(NSData * __nonnull)keyData;

- (NSData * __nonnull)exportPrivateKey:(VSSPrivateKey * __nonnull)privateKey password:(NSString * __nullable)password;
- (NSData * __nonnull)exportPublicKey:(VSSPublicKey * __nonnull)publicKey;

- (NSData * __nonnull)encryptData:(NSData * __nonnull)data forRecipients:(NSArray<VSSPublicKey *> * __nonnull)recipients;
- (void)encryptStream:(NSInputStream * __nonnull)stream outputStream:(NSOutputStream * __nonnull)outputStream forRecipients:(NSArray<VSSPublicKey *> * __nonnull)recipients;

- (bool)verifyData:(NSData * __nonnull)data signature:(NSData * __nonnull)signature signer:(VSSPublicKey * __nonnull)signer;
- (bool)verifyStream:(NSInputStream * __nonnull)inputStream signature:(NSData * __nonnull)signature signer:(VSSPublicKey * __nonnull)signer;
- (bool)verifyFingerprint:(NSString * __nonnull)fingerprint signature:(NSData * __nonnull)signature signer:(VSSPublicKey * __nonnull)signer;

- (NSData * __nonnull)decryptData:(NSData * __nonnull)data privateKey:(VSSPrivateKey * __nonnull)privateKey;
- (void)decryptStream:(NSInputStream * __nonnull)inputStream outputStream:(NSOutputStream * __nonnull)outputStream privateKey:(VSSPrivateKey * __nonnull)privateKey;

- (NSData * __nonnull)signData:(NSData * __nonnull)data privateKey:(VSSPrivateKey * __nonnull)privateKey;
- (NSData * __nonnull)signStream:(NSInputStream * __nonnull)stream privateKey:(VSSPrivateKey * __nonnull)privateKey;
- (NSData * __nonnull)signFingerprint:(NSString * __nonnull)fingerprint privateKey:(VSSPrivateKey * __nonnull)privateKey;

- (NSData * __nonnull)signAndEncryptData:(NSData * __nonnull)data privateKey:(VSSPrivateKey * __nonnull)privatekey forRecipients:(NSArray<VSSPublicKey *> * __nonnull)recipients;
- (NSData * __nonnull)descryptAndVerifyData:(NSData * __nonnull)data privateKey:(VSSPrivateKey * __nonnull)privateKey publicKey:(VSSPublicKey * __nonnull)publicKey;

- (NSString * __nonnull)calculateFingerprintOfData:(NSData * __nonnull)data;

- (NSData * __nonnull)computeHashOfData:(NSData * __nonnull)data withAlgorithm:(VSSHashAlgorithm)algorithm;

@end
