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

- (VSSKeyPair * __nonnull)generateKey;

- (VSSPrivateKey * __nullable)importPrivateKey:(NSData * __nonnull)keyData password:(NSString * __nullable)password;
- (VSSPublicKey * __nullable)importPublicKey:(NSData * __nonnull)keyData;
- (VSSPublicKey * __nonnull)extractPublicKeyFromPrivateKey:(VSSPrivateKey * __nonnull)privateKey;

- (NSData * __nonnull)exportPrivateKey:(VSSPrivateKey * __nonnull)privateKey password:(NSString * __nullable)password;
- (NSData * __nonnull)exportPublicKey:(VSSPublicKey * __nonnull)publicKey;

- (NSData * __nullable)encryptData:(NSData * __nonnull)data forRecipients:(NSArray<VSSPublicKey *> * __nonnull)recipients error:(NSError * __nullable * __nullable)errorPtr;
- (void)encryptStream:(NSInputStream * __nonnull)stream outputStream:(NSOutputStream * __nonnull)outputStream forRecipients:(NSArray<VSSPublicKey *> * __nonnull)recipients error:(NSError * __nullable * __nullable)errorPtr;

- (bool)verifyData:(NSData * __nonnull)data signature:(NSData * __nonnull)signature signerPublicKey:(VSSPublicKey * __nonnull)signerPublicKey error:(NSError * __nullable * __nullable)errorPtr;
- (bool)verifyStream:(NSInputStream * __nonnull)inputStream signature:(NSData * __nonnull)signature signerPublicKey:(VSSPublicKey * __nonnull)signerPublicKey error:(NSError * __nullable * __nullable)errorPtr;

- (NSData * __nullable)decryptData:(NSData * __nonnull)data privateKey:(VSSPrivateKey * __nonnull)privateKey error:(NSError * __nullable * __nullable)errorPtr;
- (void)decryptStream:(NSInputStream * __nonnull)inputStream outputStream:(NSOutputStream * __nonnull)outputStream privateKey:(VSSPrivateKey * __nonnull)privateKey error:(NSError * __nullable * __nullable)errorPtr;

- (NSData * __nullable)signData:(NSData * __nonnull)data privateKey:(VSSPrivateKey * __nonnull)privateKey error:(NSError * __nullable * __nullable)errorPtr;
- (NSData * __nullable)signStream:(NSInputStream * __nonnull)stream privateKey:(VSSPrivateKey * __nonnull)privateKey error:(NSError * __nullable * __nullable)errorPtr;

- (VSSFingerprint * __nonnull)calculateFingerprintForData:(NSData * __nonnull)data;

- (NSData * __nonnull)computeHashForData:(NSData * __nonnull)data withAlgorithm:(VSSHashAlgorithm)algorithm;

@end
