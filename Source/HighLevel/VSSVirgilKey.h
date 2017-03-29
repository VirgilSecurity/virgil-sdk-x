//
//  VSSVirgilKey.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 2/14/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VSSVirgilCard.h"

/**
 Class representing key.
 */
@interface VSSVirgilKey : NSObject

/**
 Generates signature for data.

 @param data NSData from which signature will be calculated
 @param errorPtr NSError pointer to return error if needed
 @return NSData with signature
 */
- (NSData * __nullable)generateSignatureForData:(NSData * __nonnull)data error:(NSError * __nullable * __nullable)errorPtr;

/**
 Generates signature for string.
 NOTE: string is converted to binary representation using UTF8 encoding.

 @param string NSString from which signature will be calculated
 @param errorPtr NSError pointer to return error if needed
 @return NSData with signature
 */
- (NSData * __nullable)generateSignatureForString:(NSString * __nonnull)string error:(NSError * __nullable * __nullable)errorPtr;

/**
 Decrypts data.

 @param data NSData with encrypted data
 @param errorPtr NSError pointer to return error if needed
 @return NSData with decrypted data
 */
- (NSData * __nullable)decryptData:(NSData * __nonnull)data error:(NSError * __nullable * __nullable)errorPtr NS_SWIFT_NAME(decrypt(_:));

/**
 Decrypts data.

 @param base64String NSString with encrypted data in base64 format
 @param errorPtr NSError pointer to return error if needed
 @return NSData with decrypted data
 */
- (NSData * __nullable)decryptBase64String:(NSString * __nonnull)base64String error:(NSError * __nullable * __nullable)errorPtr NS_SWIFT_NAME(decrypt(base64:));

/**
 Signs and encrypts data.

 @param data NSData with data to be signed and encrypted
 @param recipients list of VSSVirgilCard instances whose owners will be able to decrypt data
 @param errorPtr NSError pointer to return error if needed
 @return NSData with signed and encrypted data
 */
- (NSData * __nullable)signThenEncryptData:(NSData * __nonnull)data forRecipients:(NSArray<VSSVirgilCard *> * __nonnull)recipients error:(NSError * __nullable * __nullable)errorPtr NS_SWIFT_NAME(signThenEncrypt(_:for:));

/**
 Signs and encrypts string.
 NOTE: string is converted to binary representation using UTF8 encoding.

 @param string NSString with string to be signed and encrypted
 @param recipients list of VSSVirgilCard instances whose owners will be able to decrypt data
 @param errorPtr NSError pointer to return error if needed
 @return  NSData with signed and encrypted data
 */
- (NSData * __nullable)signThenEncryptString:(NSString * __nonnull)string forRecipients:(NSArray<VSSVirgilCard *> * __nonnull)recipients error:(NSError * __nullable * __nullable)errorPtr NS_SWIFT_NAME(signThenEncrypt(_:for:));

/**
 Decrypts and verifies data.

 @param data NSData with signed and encrypted data
 @param card VSSVirgilCard of person who encrypted and signed data
 @param errorPtr NSError pointer to return error if needed
 @return decrypted and verified data
 */
- (NSData * __nullable)decryptThenVerifyData:(NSData * __nonnull)data from:(VSSVirgilCard * __nonnull)card error:(NSError * __nullable * __nullable)errorPtr NS_SWIFT_NAME(decryptThenVerify(_:from:));

/**
 Decrypts and verifies data.

 @param data NSData with signed and encrypted data
 @param cards list of VSSVirgilCard instance of persons who could encrypt and sign data. Verification checks for correct signature from AT LEAST ONE Virgil Card from the list.
 @param errorPtr NSError pointer to return error if needed
 @return decrypted and verified data
 */
- (NSData * __nullable)decryptThenVerifyData:(NSData * __nonnull)data fromOneOf:(NSArray<VSSVirgilCard *> * __nonnull)cards error:(NSError * __nullable * __nullable)errorPtr NS_SWIFT_NAME(decryptThenVerify(_:fromOneOf:));

/**
 Decrypts and verifies data.

 @param base64String NSString with signed and encrypted data in base64 format
 @param card VSSVirgilCard of person who encrypted and signed data
 @param errorPtr NSError pointer to return error if needed
 @return decrypted and verified data
 */
- (NSData * __nullable)decryptThenVerifyBase64String:(NSString * __nonnull)base64String from:(VSSVirgilCard * __nonnull)card error:(NSError * __nullable * __nullable)errorPtr NS_SWIFT_NAME(decryptThenVerify(base64:from:));

/**
 Decrypts and verifies data.

 @param base64String NSString with signed and encrypted data in base64 format
 @param cards list of VSSVirgilCard instance of persons who could encrypt and sign data. Verification checks for correct signature from AT LEAST ONE Virgil Card from the list.
 @param errorPtr NSError pointer to return error if needed
 @return decrypted and verified data
 */
- (NSData * __nullable)decryptThenVerifyBase64String:(NSString * __nonnull)base64String fromOneOf:(NSArray<VSSVirgilCard *> * __nonnull)cards error:(NSError * __nullable * __nullable)errorPtr NS_SWIFT_NAME(decryptThenVerify(base64:fromOneOf:));

/**
 Stores key in storage.

 @param name NSString with key name
 @param password NSString with key password
 @param meta NSDictionary with any meta data
 @param errorPtr NSError pointer to return error if needed
 @return YES if succeeded, NO otherwise.
 */
- (BOOL)storeWithName:(NSString * __nonnull)name password:(NSString * __nullable)password meta:(NSDictionary<NSString *, NSString *> * __nullable)meta error:(NSError * __nullable * __nullable)errorPtr;

/**
 Stores key in storage.
 
 @param name NSString with key name
 @param password NSString with key password
 @param errorPtr NSError pointer to return error if needed
 @return YES if succeeded, NO otherwise.
 */
- (BOOL)storeWithName:(NSString * __nonnull)name password:(NSString * __nullable)password error:(NSError * __nullable * __nullable)errorPtr;

/**
 Exports public key.

 @return NSData with exported public key
 */
- (NSData * __nonnull)exportPublicKey;

/**
 Exports private key.

 @param password NSString with password
 @return NSData with exported private key
 */
- (NSData * __nonnull)exportWithPassword:(NSString * __nullable)password;

/**
 Unavailable no-argument initializer inherited from NSObject
 */
- (instancetype __nonnull)init NS_UNAVAILABLE;

@end
