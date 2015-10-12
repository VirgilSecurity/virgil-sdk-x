//
//  VSSResetPublicKeyRequest.h
//  VirgilKeysSDK
//
//  Created by Pavel Gorb on 9/13/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import "VSSKeysBaseRequest.h"
#import <VirgilFrameworkiOS/VSSTypes.h>

@class VSSActionToken;

@interface VSSResetPublicKeyRequest : VSSKeysBaseRequest

@property (nonatomic, strong, readonly) VSSActionToken * __nullable actionToken;

- (instancetype __nonnull)initWithBaseURL:(NSString * __nonnull)url publicKeyId:(GUID * __nonnull)publicKeyId publicKey:(NSData * __nonnull)publicKey;

@end
