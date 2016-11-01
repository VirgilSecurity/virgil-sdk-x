//
//  VSSPrivateKey.h
//  VirgilKeys
//
//  Created by Pavel Gorb on 1/29/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSBaseModel.h"
#import "VSSPublicKey.h"

/**
 Container for private key which is used for crypto operations.
 You can import/export VSSPrivateKey from/to raw represenation. See VSSCrypto protocol.
 */
@interface VSSPrivateKey : NSObject

/**
 Unavailable no-argument initializer inherited from NSObject
 */
- (instancetype __nonnull)init NS_UNAVAILABLE;

@end
