//
//  VSSRequestSigner.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 10/3/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "VSSRequestSignerProtocol.h"
#import "VSSCryptoProtocol.h"
#import "VSSPrivateKey.h"
#import "VSSPublicKey.h"
#import "VSSSignable.h"

/**
 NSString with Error Domain used for VSSRequestSigner-related errors.
 */
extern NSString * __nonnull const kVSSRequestSignerErrorDomain;

/**
 Class used for signing VSSSignableRequest instances (like VSSCreateCardRequest or VSSRevokeCardRequest).
 */
@interface VSSRequestSigner : NSObject <VSSRequestSigner>

/**
 Implementation of VSSCrypto protocol used for calculation signatures.
 */
@property (nonatomic, readonly) id<VSSCrypto> __nonnull crypto;

/**
 Designated initializer.

 @param crypto implementation of VSSCrypto protocol

 @return initialized VSSRequestSigner instance
 */
- (instancetype __nonnull)initWithCrypto:(id<VSSCrypto> __nonnull)crypto NS_DESIGNATED_INITIALIZER;

/**
 Unavailable no-argument initializer inherited from NSObject
 */
- (instancetype __nonnull)init NS_UNAVAILABLE;

/**
 Calculates id for request.

 @param request VSSSignableRequest instance from which id will be calculated
 @return NSString with calculated id
 */
- (NSString * __nonnull)getCardIdForRequest:(id<VSSSignable> __nonnull)request;

@end
