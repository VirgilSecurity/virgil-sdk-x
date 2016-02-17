//
//  VSSCreateCardRequest.h
//  VirgilSDK
//
//  Created by Pavel Gorb on 2/3/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//


#import "VSSKeysBaseRequest.h"
#import "VSSModelTypes.h"

@class VSSPublicKey;
@class VSSCard;

@interface VSSCreateCardRequest : VSSKeysBaseRequest

@property (nonatomic, strong, readonly) VSSCard * __nullable card;

- (instancetype __nonnull)initWithContext:(VSSRequestContext * __nonnull)context publicKeyId:(GUID * __nonnull)pkId identity:(NSDictionary * __nonnull)identity data:(NSDictionary * __nullable)data signs:(NSArray <NSDictionary *>* __nullable)signs NS_DESIGNATED_INITIALIZER;
- (instancetype __nonnull)initWithContext:(VSSRequestContext * __nonnull)context publicKey:(NSData * __nonnull)publicKey identity:(NSDictionary * __nonnull)identity data:(NSDictionary * __nullable)data signs:(NSArray <NSDictionary *>* __nullable)signs NS_DESIGNATED_INITIALIZER;

@end
