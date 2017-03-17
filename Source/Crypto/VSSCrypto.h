//
//  VSSCrypto.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 9/29/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSCryptoProtocol.h"
#import "VSSCryptoCommons.h"

/**
 VSSCrypto protocol default implementation. See VSSCrypto protocol.
 */
@interface VSSCrypto : NSObject <VSSCrypto>

/**
 Initializes VSSCrypto instances and sets default key type for generated keys.

 @param keyType see VSSKeyType
 @return initialized instance
 */
- (instancetype __nonnull)initWithDefaultKeyType:(VSSKeyType)keyType;

/**
 Generates key pair of chosen type

 @param type see VSSKeyType
 @return generated VSSKeyPair
 */
- (VSSKeyPair * __nonnull)generateKeyPairOfType:(VSSKeyType)type;

/**
 Computes hash for data using chosen algorithm
 
 @param data      NSData instance with data of which hash will be calculated
 @param algorithm Algorithm used for hash calculation. See VSSHashAlgorithm
 
 @return NSData instance with hash
 */
- (NSData * __nonnull)computeHashForData:(NSData * __nonnull)data withAlgorithm:(VSSHashAlgorithm)algorithm;

@end
