//
//  VSSSearchCardRequest.h
//  VirgilSDK
//
//  Created by Pavel Gorb on 2/4/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSKeysBaseRequest.h"
#import "VSSModelCommons.h"

@class VSSCard;
@class VSSPublicKey;
@class VSSIdentityInfo;

@interface VSSSearchCardRequest : VSSKeysBaseRequest

@property (nonatomic, strong, readonly) NSArray <VSSCard *>* __nullable cards;

- (instancetype __nonnull)initWithContext:(VSSRequestContext * __nonnull)context identityInfo:(VSSIdentityInfo * __nonnull)identityInfo relations:(NSArray <GUID *>* __nullable)relations unconfirmed:(BOOL)unconfirmed NS_DESIGNATED_INITIALIZER;

@end
