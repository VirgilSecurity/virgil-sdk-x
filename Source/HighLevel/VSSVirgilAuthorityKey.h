//
//  VSSVirgilAuthorityKey.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 11/10/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "VSSVirgilBaseKey.h"

@interface VSSVirgilAuthorityKey : VSSVirgilBaseKey

+ (instancetype __nullable)virgilAuthorityKeyWithData:(NSData * __nonnull)data password:(NSString * __nullable)password forAppId:(NSString * __nonnull)appId;

+ (instancetype __nullable)virgilAuthorityKeyWithURL:(NSURL * __nonnull)url password:(NSString * __nullable)password forAppId:(NSString * __nonnull)appId;

- (instancetype __nonnull)initWithKeyPair:(VSSKeyPair * __nonnull)keyPair NS_UNAVAILABLE;

/**
 Unavailable no-argument initializer inherited from NSObject
 */
- (instancetype __nonnull)init NS_UNAVAILABLE;

@end
