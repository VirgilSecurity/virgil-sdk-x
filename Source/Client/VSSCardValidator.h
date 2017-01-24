//
//  VSSCardValidator.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 10/5/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VSSCardValidatorProtocol.h"
#import "VSSCryptoProtocol.h"

/**
 Default implementation of VSSCardValidator protocol.
 By default verifies VSSCreateCardRequest owner signature and Virgil Cards Service signature.
 Override NSCopying behaviour if you decided to subclass this interface.
 */
@interface VSSCardValidator : NSObject <VSSCardValidator, NSCopying>

/**
 NSDictionary which stores NSString with verifier id as Key and its VSSPublicKey as Value
 */
@property (nonatomic, copy, readonly) NSDictionary<NSString *, VSSPublicKey *> * __nonnull verifiers;

/**
 Designated initializer.

 @param crypto implementation of VSSCrypto protocol

 @return initialized VSSCardValidator instance
 */
- (instancetype __nonnull)initWithCrypto:(id<VSSCrypto> __nonnull)crypto NS_DESIGNATED_INITIALIZER;

/**
 Unavailable no-argument initializer inherited from NSObject
 */
- (instancetype __nonnull)init NS_UNAVAILABLE;

/**
 Adds verifier.

 @param verifierId    NSString which represents verifier ID
 @param publicKeyData NSData with verifier Public Key (for example Application Public Key)
 */
- (BOOL)addVerifierWithId:(NSString * __nonnull)verifierId publicKeyData:(NSData * __nonnull)publicKeyData;

@end
