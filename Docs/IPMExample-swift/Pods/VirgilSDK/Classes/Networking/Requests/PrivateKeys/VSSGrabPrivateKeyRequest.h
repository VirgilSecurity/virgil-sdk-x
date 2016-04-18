//
//  VSSGrabPrivateKeyRequest.h
//  VirgilKeys
//
//  Created by Pavel Gorb on 2/17/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSPrivateKeysBaseRequest.h"
#import "VSSModelTypes.h"

@interface VSSGrabPrivateKeyRequest : VSSPrivateKeysBaseRequest

@property (nonatomic, strong, readonly) NSData * __nullable privateKey;
@property (nonatomic, strong, readonly) GUID * __nullable cardId;

- (instancetype __nonnull)initWithContext:(VSSRequestContext * __nonnull)context identity:(NSDictionary * __nonnull)identity cardId:(GUID * __nonnull)cardId NS_DESIGNATED_INITIALIZER;

@end
