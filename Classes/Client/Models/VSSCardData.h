//
//  VSSCardData.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 9/26/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VSSModelCommons.h"
#import "VSSBaseModel.h"

@interface VSSCardData : VSSBaseModel

@property (nonatomic, copy, readonly) NSString * __nonnull identity;
@property (nonatomic, copy, readonly) NSString * __nonnull identityType;
@property (nonatomic, copy, readonly) NSData * __nonnull publicKey;
@property (nonatomic, copy, readonly) NSDictionary * __nonnull data;
@property (nonatomic, readonly) VSSCardScope scope;
@property (nonatomic, copy, readonly) NSDictionary * __nonnull info;

+ (instancetype __nullable)createWithIdentity:(NSString * __nonnull)identity identityType:(NSString * __nonnull)identityType publicKey:(NSData * __nonnull)publicKey data:(NSDictionary * __nullable)data;
+ (instancetype __nullable)createWithIdentity:(NSString * __nonnull)identity identityType:(NSString * __nonnull)identityType publicKey:(NSData * __nonnull)publicKey;

+ (instancetype __nullable)createGlobalWithIdentity:(NSString * __nonnull)identity publicKey:(NSData * __nonnull)publicKey;
+ (instancetype __nullable)createGlobalWithIdentity:(NSString * __nonnull)identity publicKey:(NSData * __nonnull)publicKey data:(NSDictionary * __nullable)data;

- (instancetype __nonnull)init NS_UNAVAILABLE;

@end
