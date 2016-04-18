//
//  VSSRequestContextExtended.h
//  VirgilKeys
//
//  Created by Pavel Gorb on 2/10/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSRequestContext.h"
#import "VSSModelTypes.h"

@class VSSCard;
@class VSSPrivateKey;

@interface VSSRequestContextExtended : VSSRequestContext

@property (nonatomic, strong, readonly) VSSCard* __nullable serviceCard;
@property (nonatomic, strong, readonly) NSNumber * __nullable requestEncrypt;
@property (nonatomic, strong, readonly) NSNumber * __nullable responseVerify;

@property (nonatomic, strong, readonly) VSSPrivateKey * __nullable privateKey;
@property (nonatomic, strong, readonly) GUID * __nullable cardId;
@property (nonatomic, strong, readonly) NSString * __nullable password;

- (instancetype __nonnull)initWithServiceUrl:(NSString * __nonnull)serviceUrl serviceCard:(VSSCard * __nullable)serviceCard requestEncrypt:(NSNumber * __nullable)requestEncrypt responseVerify:(NSNumber * __nullable)responseVerify privateKey:(VSSPrivateKey * __nullable)privateKey cardId:(GUID * __nullable)cardId password:(NSString * __nullable)password NS_DESIGNATED_INITIALIZER;

@end
