//
//  VSSCardData.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 9/28/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSCardData.h"
#import "VSSCanonicalRepresentable.h"
#import "VSSSerializable.h"
#import "VSSDeserializable.h"

@interface VSSCardData () <VSSSerializable, VSSDeserializable, VSSCanonicalRepresentable>

+ (instancetype __nullable)createWithIdentity:(NSString * __nonnull)identity identityType:(NSString * __nonnull)identityType scope:(VSSCardScope)scope publicKey:(NSData * __nonnull)publicKey data:(NSDictionary * __nullable)data;

- (instancetype __nullable)initWithIdentity:(NSString * __nonnull)identity identityType:(NSString * __nonnull)identityType scope:(VSSCardScope)scope publicKey:(NSData * __nonnull)publicKey data:(NSDictionary * __nullable)data info:(NSDictionary * __nonnull)info;

@end
