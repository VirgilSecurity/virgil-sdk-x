//
//  VSSCard.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 9/29/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSSignedData.h"
#import "VSSCardData.h"

@interface VSSCard : VSSSignedData

@property (nonatomic, copy, readonly) VSSCardData * __nonnull data;

+ (instancetype __nonnull)cardWithIdentity:(NSString * __nonnull)identity identityType:(NSString * __nonnull)identityType publicKey:(NSData * __nonnull)publicKey data:(NSDictionary * __nullable)data;
+ (instancetype __nonnull)cardWithIdentity:(NSString * __nonnull)identity identityType:(NSString * __nonnull)identityType publicKey:(NSData * __nonnull)publicKey;

//+ (instancetype __nullable)cardGlobalWithIdentity:(NSString * __nonnull)identity publicKey:(NSData * __nonnull)publicKey;
//+ (instancetype __nullable)cardGlobalWithIdentity:(NSString * __nonnull)identity publicKey:(NSData * __nonnull)publicKey data:(NSDictionary * __nullable)data;

- (instancetype __nonnull)initWithSignatures:(NSDictionary * __nullable)signatures cardVersion:(NSString * __nullable)cardVersion createdAt:(NSDate * __nullable)createdAt NS_UNAVAILABLE;

@end
