//
//  VSSDeletePublicKeyRequest.h
//  VirgilSDK
//
//  Created by Pavel Gorb on 9/13/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import "VSSKeysBaseRequest.h"
#import "VSSModelTypes.h"

@interface VSSDeletePublicKeyRequest : VSSKeysBaseRequest

- (instancetype __nonnull)initWithContext:(VSSRequestContext * __nonnull)context publicKeyId:(GUID * __nonnull)publicKeyId identities:(NSArray <NSDictionary*>* __nonnull)identities NS_DESIGNATED_INITIALIZER;

@end
