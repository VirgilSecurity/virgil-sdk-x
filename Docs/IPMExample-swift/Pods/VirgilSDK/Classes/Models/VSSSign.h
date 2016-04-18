//
//  VSSSign.h
//  VirgilKeys
//
//  Created by Pavel Gorb on 2/3/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSBaseModel.h"
#import "VSSModelTypes.h"

@interface VSSSign : VSSBaseModel

@property (nonatomic, copy, readonly) GUID * __nonnull signedCardId;
@property (nonatomic, copy, readonly) NSData * __nonnull digest;

@property (nonatomic, copy, readonly) GUID * __nullable signerCardId;
@property (nonatomic, copy, readonly) NSDictionary * __nullable data;

- (instancetype __nonnull)initWithId:(GUID * __nonnull)Id createdAt:(NSDate * __nullable)createdAt signedCardId:(GUID * __nonnull)signedId digest:(NSData * __nonnull)digest signerCardId:(GUID * __nullable)signerId data:(NSDictionary * __nullable)data NS_DESIGNATED_INITIALIZER;

@end
