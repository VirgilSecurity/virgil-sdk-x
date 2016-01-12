//
//  VSSPersistPublicKeyRequest.h
//  VirgilKeysSDK
//
//  Created by Pavel Gorb on 9/13/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import "VSSKeysBaseRequest.h"
#import <VirgilKit/VSSTypes.h>

@class VSSPublicKey;
@class VSSActionToken;

@interface VSSPersistPublicKeyRequest : VSSKeysBaseRequest

@property (nonatomic, strong, readonly) VSSPublicKey * __nullable publicKey;

- (instancetype __nonnull)initWithBaseURL:(NSString * __nonnull)url publicKeyId:(GUID * __nonnull)publicKeyId actionToken:(VSSActionToken * __nonnull)actionToken NS_DESIGNATED_INITIALIZER;

@end
