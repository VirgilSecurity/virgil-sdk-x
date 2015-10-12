//
//  VKGetPublicKeyRequest.h
//  VirgilKeysSDK
//
//  Created by Pavel Gorb on 9/13/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import "VKBaseRequest.h"
#import <VirgilFrameworkiOS/VFTypes.h>

@class VKPublicKey;

@interface VKGetPublicKeyRequest : VKBaseRequest

@property (nonatomic, strong, readonly) VKPublicKey * __nullable publicKey;

- (instancetype __nonnull)initWithBaseURL:(NSString * __nonnull)url publicKeyId:(GUID * __nonnull)pkId NS_DESIGNATED_INITIALIZER;

@end
