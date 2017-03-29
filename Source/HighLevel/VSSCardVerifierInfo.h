//
//  VSSCardVerifierInfo.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 3/8/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Class represents info about Virgil Card verifiers.
 */
@interface VSSCardVerifierInfo : NSObject

/**
 NSString with verifier's card identifier.
 */
@property (nonatomic, readonly) NSString * __nonnull cardId;

/**
 NSData with verifier's public key.
 */
@property (nonatomic, readonly) NSData * __nonnull publicKeyData;

/**
 Initializes instance.

 @param cardId NSString with verifier's card identifier
 @param publicKeyData NSData with verifier's public key
 @return initialized VSSCardVerifierInfo instance
 */
- (instancetype __nonnull)initWithCardId:(NSString * __nonnull)cardId publicKeyData:(NSData * __nonnull)publicKeyData NS_DESIGNATED_INITIALIZER;

/**
 Unavailable no-argument initializer inherited from NSObject
 */
- (instancetype __nonnull)init NS_UNAVAILABLE;

@end
