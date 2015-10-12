//
//  VSSCreatePublicKeyRequest.h
//  VirgilKeysSDK
//
//  Created by Pavel Gorb on 9/12/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import "VSSKeysBaseRequest.h"

@class VSSPublicKey;

@interface VSSCreatePublicKeyRequest : VSSKeysBaseRequest

@property (nonatomic, strong, readonly) VSSPublicKey * __nullable publicKey;

- (instancetype __nonnull)initWithBaseURL:(NSString * __nonnull)url publicKey:(VSSPublicKey * __nonnull)key NS_DESIGNATED_INITIALIZER;

@end
