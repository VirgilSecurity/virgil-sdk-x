//
//  VSSUpdatePublicKeyRequest.h
//  VirgilKeysSDK
//
//  Created by Pavel Gorb on 9/13/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import "VSSKeysBaseRequest.h"
#import <VirgilKit/VSSTypes.h>

@class VSSPublicKey;
@class VSSKeyPair;

@interface VSSUpdatePublicKeyRequest : VSSKeysBaseRequest

@property (nonatomic, strong, readonly) VSSPublicKey * __nullable publicKey;

- (instancetype __nonnull)initWithBaseURL:(NSString * __nonnull)url publicKeyId:(GUID * __nonnull)pkId newKeyPair:(VSSKeyPair * __nonnull)keyPair keyPassword:(NSString * __nullable)keyPassword NS_DESIGNATED_INITIALIZER;

@end
