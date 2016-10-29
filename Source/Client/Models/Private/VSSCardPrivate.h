//
//  VSSCardPrivate.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 10/27/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSCard.h"

@interface VSSCard ()

- (instancetype __nonnull)initWithIdentifier:(NSString * __nonnull)identifier identity:(NSString * __nonnull)identity identityType:(NSString * __nonnull)identityType publicKey:(NSData * __nonnull)publicKey scope:(VSSCardScope)scope data:(NSDictionary<NSString *, NSString *> * __nullable)data info:(NSDictionary<NSString *, NSString *> * __nullable)info createdAt:(NSDate * __nonnull)createdAt cardVersion:(NSString * __nonnull)cardVersion;

@end
