//
//  VSSDeletePublicKeyRequest.h
//  VirgilKeysSDK
//
//  Created by Pavel Gorb on 9/13/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import "VSSKeysBaseRequest.h"
#import <VirgilKit/VSSTypes.h>

@class VSSActionToken;

@interface VSSDeletePublicKeyRequest : VSSKeysBaseRequest

@property (nonatomic, strong, readonly) VSSActionToken * __nullable actionToken;

- (instancetype __nonnull)initWithBaseURL:(NSString * __nonnull)url publicKeyId:(GUID * __nonnull)publicKeyId NS_DESIGNATED_INITIALIZER;

@end
