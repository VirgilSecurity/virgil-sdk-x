//
//  VSSKeysManager.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 12/23/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSKeysManagerProtocol.h"

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
