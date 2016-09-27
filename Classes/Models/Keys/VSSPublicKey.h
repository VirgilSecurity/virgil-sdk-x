//
//  VSSPublicKey.h
//  VirgilSDK
//
//  Created by Pavel Gorb on 9/7/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VSSModel.h"
#import "VSSModelCommons.h"
#import "VSSStringRepresentable.h"

/**
 * Wrapper class representing the public key of the particular user or owner of the Virgil Card.
 */
@interface VSSPublicKey : VSSModel

- (instancetype __nonnull)init NS_UNAVAILABLE;

@end
