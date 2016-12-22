//
//  VSSVirgilKey.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 11/8/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "VSSVirgilBaseKey.h"
#import "VSSKeyPair.h"
#import "VSSCreateCardRequest.h"

extern NSString * __nonnull const kVSSVirgilKeyErrorDomain;

@interface VSSVirgilKey : VSSVirgilBaseKey

+ (instancetype __nullable)virgilKeyWithName:(NSString * __nonnull)name keyPair:(VSSKeyPair * __nonnull)keyPair;

+ (instancetype __nullable)virgilKeyWithName:(NSString * __nonnull)name;

- (NSData * __nonnull)exportWithPassword:(NSString * __nullable)password;

- (VSSCreateCardRequest * __nullable)buildCreateCardRequestWithIdentity:(NSString * __nonnull)identity identityType:(NSString * __nonnull)identityType data:(NSDictionary<NSString *, NSString *> * __nullable)data error:(NSError * __nullable * __nullable)errorPtr;

/**
 Unavailable no-argument initializer inherited from NSObject
 */
- (instancetype __nonnull)init NS_UNAVAILABLE;

@end
