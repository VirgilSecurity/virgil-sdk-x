//
//  VSSKeysManager.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 12/23/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VSSKeysManagerProtocol.h"

/**
 NSString with Error Domain used for VSSKeysManager-related errors
 */
extern NSString * __nonnull const kVSSKeysManagerErrorDomain;

/**
 Implementation of VSSKeysManager protocol.
 VSSKeysManager should not be created by user and is accessible only using VSSVirgilApi.
 */
@interface VSSKeysManager : NSObject<VSSKeysManager>

/**
 Unavailable no-argument initializer inherited from NSObject
 */
- (instancetype __nonnull)init NS_UNAVAILABLE;

@end
