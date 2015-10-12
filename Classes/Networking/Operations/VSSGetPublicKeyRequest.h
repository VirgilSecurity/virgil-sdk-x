//
//  VSSGetPublicKeyRequest.h
//  VirgilKeysSDK
//
//  Created by Pavel Gorb on 9/13/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import "VSSKeysBaseRequest.h"
#import <VirgilFrameworkiOS/VSSTypes.h>

@class VSSPublicKey;

@interface VSSGetPublicKeyRequest : VSSKeysBaseRequest

@property (nonatomic, strong, readonly) VSSPublicKey * __nullable publicKey;

- (instancetype __nonnull)initWithBaseURL:(NSString * __nonnull)url publicKeyId:(GUID * __nonnull)pkId NS_DESIGNATED_INITIALIZER;

@end
