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

/**
 Protocol for all cryptographic operations.
 */
@protocol VSSCrypto <NSObject>

///------------------------------------------
/// @name Key-related functionality
///------------------------------------------

/**
 Generates key pair using ed25519 algorithm.
 See VSSKeyPair.

 @return generated VSSKeyPair instance
 */
- (VSSKeyPair * __nonnull)generateKeyPair;

/**
 Imports Private Key with password from NSData raw representation.

 @param data     NSData raw representation of Private Key
 @param password NSString password for Private Key

 @return imported VSSPrivateKey instance
 */
- (VSSPrivateKey * __nullable)importPrivateKeyFromData:(NSData * __nonnull)data withPassword:(NSString * __nullable)password;

/**
 Imports Private Key without password from NSData raw representation.

 @param data NSData raw representation of Private Key

 @return imported VSSPrivateKey instance
 */
- (VSSPrivateKey * __nullable)importPrivateKeyFromData:(NSData * __nonnull)data;

/**
 Imports Public Key from NSData raw representation.

 @param data NSData Public Key raw representation

 @return imported VSSPublicKey instance
 */
- (VSSPublicKey * __nullable)importPublicKeyFromData:(NSData * __nonnull)data;

/**
 Extracts corresponding Public Key from Private Key.

 @param privateKey VSSPrivateKey instance

 @return extracted VSSPublicKey
 */
- (VSSPublicKey * __nonnull)extractPublicKeyFromPrivateKey:(VSSPrivateKey * __nonnull)privateKey NS_SWIFT_NAME(extractPublicKey(from:));

/**
 Exports Private Key to raw NSData representation.

 @param privateKey VSSPrivateKey instance
 @param password   NSString with password for export

 @return NSData raw representation of Private Key
 */
- (NSData * __nonnull)exportPrivateKey:(VSSPrivateKey * __nonnull)privateKey withPassword:(NSString * __nullable)password;

/**
 Exports Public Key to raw NSData representation.

 @param publicKey VSSPublicKey instance

 @return NSData raw representation of Public Key
 */
- (NSData * __nonnull)exportPublicKey:(VSSPublicKey * __nonnull)publicKey;

///------------------------------------------
/// @name Encrypt/Decrypt-related functionality
///------------------------------------------

/**
 Encrypts data.
 Only those, who have VSSPrivateKey corresponding to one of VSSPublicKey in recipients array will be able to decrypt data.

 @param data       NSData instance with any sensitive data
 @param recipients NSArray of VSSPublicKey instances corresponding to recipients
 @param errorPtr   NSError pointer to return error if needed

 @return NSData instance with encrypted data
 */
- (NSData * __nullable)encryptData:(NSData * __nonnull)data forRecipients:(NSArray<VSSPublicKey *> * __nonnull)recipients error:(NSError * __nullable * __nullable)errorPtr NS_SWIFT_NAME(encrypt(_:for:));

/**
 Encrypts stream.
 Only those, who have VSSPrivateKey corresponding to one of VSSPublicKey in recipients array will be able to decrypt stream.
 
 @param stream       NSInputStream isntance with incoming data
 @param outputStream NSOutputStream with encrypted data
 @param recipients   NSArray of VSSPublicKey instances corresponding to recipients
 @param errorPtr     NSError pointer to return error if needed

 @return BOOL value which indicates whether encryption was successful or failed
 */
- (BOOL)encryptStream:(NSInputStream * __nonnull)stream toOutputStream:(NSOutputStream * __nonnull)outputStream forRecipients:(NSArray<VSSPublicKey *> * __nonnull)recipients error:(NSError * __nullable * __nullable)errorPtr NS_SWIFT_NAME(encrypt(_:to:for:));

/**
 Verifies data for genuineness.
 NOTE: verify is defined in <usr/include/AssertMacros.h> thus can't be used as base name in NS_SWIFT_NAME
 
 @param data            NSData instance with data to be verified
 @param signature       NSData instance with corresponding signature
 @param signerPublicKey VSSPublicKey instance with data signer's Public Key
 @param errorPtr        NSError pointer to return error if needed

 @return BOOL value which indicates whether data was successfully verified or verification failed
 */
- (BOOL)verifyData:(NSData * __nonnull)data withSignature:(NSData * __nonnull)signature usingSignerPublicKey:(VSSPublicKey * __nonnull)signerPublicKey error:(NSError * __nullable * __nullable)errorPtr NS_SWIFT_NAME(verifyData(_:withSignature:using:));

/**
 Verifies stream for genuineness.
 NOTE: verify is defined in <usr/include/AssertMacros.h> thus can't be used as base name in NS_SWIFT_NAME

 @param stream          NSInputStream instance with data to be verified
 @param signature       NSData instance with corresponding signature
 @param signerPublicKey VSSPublicKey instance with stream signer's Public Key
 @param errorPtr        NSError pointer to return error if needed

 @return BOOL value which indicates whether stream was successfully verified or verification failed
 */
- (BOOL)verifyStream:(NSInputStream * __nonnull)stream signature:(NSData * __nonnull)signature usingSignerPublicKey:(VSSPublicKey * __nonnull)signerPublicKey error:(NSError * __nullable * __nullable)errorPtr NS_SWIFT_NAME(verifyStream(_:withSignature:using:));

/**
 Decrypts data.

 @param data       NSData instance with encrypted data to be decrypted
 @param privateKey VSSPrivateKey instance of data recipient
 @param errorPtr   NSError pointer to return error if needed

 @return NSData instance with decrypted data
 */
- (NSData * __nullable)decryptData:(NSData * __nonnull)data withPrivateKey:(VSSPrivateKey * __nonnull)privateKey error:(NSError * __nullable * __nullable)errorPtr NS_SWIFT_NAME(decrypt(_:with:));

/**
 Decrypts stream.

 @param stream       NSInputStream with encrypted data to be decrypted
 @param outputStream NSOutputStream instance where encrypted data will be written
 @param privateKey   VSSPrivateKey instance of data recipient
 @param errorPtr     NSError pointer to return error if needed

 @return BOOL value which indicates whether encryption succeeded or failed
 */
- (BOOL)decryptStream:(NSInputStream * __nonnull)stream toOutputStream:(NSOutputStream * __nonnull)outputStream withPrivateKey:(VSSPrivateKey * __nonnull)privateKey error:(NSError * __nullable * __nullable)errorPtr NS_SWIFT_NAME(decrypt(_:to:with:));

/**
 Signs and ecrypts data.

 @param data       NSData instance with data to be signed and ecnrypted
 @param privateKey VSSPrivateKey isntance of signer
 @param recipients NSArray of VSSPublicKey instances corresponding to recipients
 @param errorPtr   NSError pointer to return error if needed

 @return NSData instance with signed and ecrypted data
 */
- (NSData * __nullable)signThenEncryptData:(NSData * __nonnull)data withPrivateKey:(VSSPrivateKey * __nonnull)privateKey forRecipients:(NSArray<VSSPublicKey *> * __nonnull)recipients error:(NSError * __nullable * __nullable)errorPtr NS_SWIFT_NAME(signThenEncrypt(_:with:for:));

/**
 Decrypts and verifies data.

 @param data            NSData instance with encrypted and signed data
 @param privateKey      VSSPrivateKey isntance of data recipient
 @param signerPublicKey VSSPublicKey instance with data signer's Public Key
 @param errorPtr        NSError pointer to return error if needed

 @return NSData instance with encrypted and verified data
 */
- (NSData * __nullable)decryptThenVerifyData:(NSData * __nonnull)data withPrivateKey:(VSSPrivateKey * __nonnull)privateKey usingSignerPublicKey:(VSSPublicKey * __nonnull)signerPublicKey error:(NSError * __nullable * __nullable)errorPtr NS_SWIFT_NAME(decryptThenVerify(_:with:using:));

///------------------------------------------
/// @name Hash-related functionality
///------------------------------------------

/**
 Generates signature for data.

 @param data       NSData with data to be signed
 @param privateKey VSSPrivateKey of signer
 @param errorPtr   NSError pointer to return error if needed

 @return NSData instance with signature
 */
- (NSData * __nullable)generateSignatureForData:(NSData * __nonnull)data withPrivateKey:(VSSPrivateKey * __nonnull)privateKey error:(NSError * __nullable * __nullable)errorPtr;

/**
 Generates signature for stream.

 @param stream     NSInputStream with data to be signed
 @param privateKey VSSPrivateKey of signer
 @param errorPtr   NSError pointer to return error if needed

 @return NSData instance with signature
 */
- (NSData * __nullable)generateSignatureForStream:(NSInputStream * __nonnull)stream withPrivateKey:(VSSPrivateKey * __nonnull)privateKey error:(NSError * __nullable * __nullable)errorPtr;

/**
 Calculates VSSFingerprint for data.

 @param data NSData instance with data of which fingerprint will be calculated

 @return VSSFingerprint instance corresponding to data
 */
- (VSSFingerprint * __nonnull)calculateFingerprintForData:(NSData * __nonnull)data;

@end
