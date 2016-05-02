//
//  VSSValidationTokenGenerator.h
//  VirgilSDK
//
//  Created by Pavel Gorb on 4/28/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VSSModelCommons.h"

@class VSSPrivateKey;
@class VSSIdentityInfo;

@interface VSSValidationTokenGenerator : NSObject

+ (NSString * __nullable)validationTokenForIdentityType:(NSString * __nonnull)type value:(NSString * __nonnull)value privateKey:(VSSPrivateKey * __nonnull)privateKey error:(NSError * __nullable * __nullable)error;
+ (void)setValidationTokenForIdentityInfo:(VSSIdentityInfo * __nonnull)identityInfo privateKey:(VSSPrivateKey * __nonnull)privateKey error:(NSError * __nullable * __nullable)error;

@end
