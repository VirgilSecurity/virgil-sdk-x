//
//  VSSSigner.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 10/3/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VSSCryptoProtocol.h"
#import "VSSPrivateKey.h"
#import "VSSPublicKey.h"
#import "VSSSignedData.h"

/**
 NSString with Error Domain used for VSSSigner-related errors.
 */
extern NSString * __nonnull const kVSSSignerErrorDomain;

/**
 Class used for signing VSSSignedData instances (like VSSCard or VSSRevokeCard).
 */
@interface VSSSigner : NSObject

/**
 Implementation of VSSCrypto protocol used for calculation signatures.
 */
@property (nonatomic, readonly) id<VSSCrypto> __nonnull crypto;

/**
 Designated initializer.

 @param crypto implementation of VSSCrypto protocol

 @return initialized VSSSigner instance
 */
- (instancetype __nonnull)initWithCrypto:(id<VSSCrypto> __nonnull)crypto NS_DESIGNATED_INITIALIZER;

/**
 Unavailable no-argument initializer inherited from NSObject
 */
- (instancetype __nonnull)init NS_UNAVAILABLE;

/**
 Adds owner's signature to given VSSSignedData using provided VSSPrivateKey

 @param data       VSSSignedData instance to be signed
 @param privateKey VSSPrivateKey which represents owner's private key and is used for calculating signature
 @param errorPtr   NSError pointer to return error if needed

 @return BOOL value which indicates whether signing succeeded or failed
 */
- (BOOL)ownerSignData:(VSSSignedData * __nonnull)data withPrivateKey:(VSSPrivateKey * __nonnull)privateKey error:(NSError * __nullable * __nullable)errorPtr;

/**
 Adds Authority signature

 @param data       VSSSignedData instance to be signed
 @param appId      NSString which represents Authority identifier (for example, AppID)
 @param privateKey VSSPrivateKey which represents authority's private key and is used for calculating signature
 @param errorPtr   NSError pointer to return error if needed

 @return BOOL value which indicates whether signing succeeded or failed
 */
- (BOOL)authoritySignData:(VSSSignedData * __nonnull)data forAppId:(NSString * __nonnull)appId withPrivateKey:(VSSPrivateKey * __nonnull)privateKey error:(NSError * __nullable * __nullable)errorPtr;

@end
