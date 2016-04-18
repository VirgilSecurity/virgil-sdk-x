//
//  VSSCard.h
//  VirgilKeys
//
//  Created by Pavel Gorb on 1/22/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSBaseModel.h"

@class VSSIdentity;
@class VSSPublicKey;

@interface VSSCard : VSSBaseModel

@property (nonatomic, copy, readonly) NSNumber * __nonnull isConfirmed;
@property (nonatomic, copy, readonly) NSString * __nonnull Hash;
@property (nonatomic, copy, readonly) VSSIdentity * __nonnull identity;
@property (nonatomic, copy, readonly) VSSPublicKey * __nonnull publicKey;

@property (nonatomic, copy, readonly) NSDictionary * __nullable data;

- (instancetype __nonnull)initWithId:(GUID * __nonnull)Id createdAt:(NSDate * __nullable)createdAt identity:(VSSIdentity * __nonnull)identity publicKey:(VSSPublicKey * __nonnull)publicKey hash:(NSString * __nonnull)theHash data:(NSDictionary * __nullable)data confirmed:(NSNumber * __nonnull)confirmed NS_DESIGNATED_INITIALIZER;

@end
