//
//  VSSPublicKey.h
//  VirgilSDK
//
//  Created by Pavel Gorb on 9/7/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VSSBaseModel.h"
#import "VSSModelCommons.h"

/**
 Container for public key which is used for crypto operations.
 You can import/export VSSPublicKey from/to raw represenation. See VSSCrypto protocol.
 */
@interface VSSPublicKey : NSObject

/**
 Unavailable no-argument initializer inherited from NSObject
 */
- (instancetype __nonnull)init NS_UNAVAILABLE;

@end
