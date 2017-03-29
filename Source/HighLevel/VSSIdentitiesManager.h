//
//  VSSIdentitiesManager.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 3/3/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

#import "VSSIdentitiesManagerProtocol.h"

/**
 Implementation of VSSIdentitiesManager protocol.
 VSSIdentitiesManager should not be created by user and is accessible only using VSSVirgilApi.
 */
@interface VSSIdentitiesManager : NSObject<VSSIdentitiesManager>

/**
 Unavailable no-argument initializer inherited from NSObject
 */
- (instancetype __nonnull)init NS_UNAVAILABLE;

@end
