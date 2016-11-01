//
//  VSSCreateCardSnapshotModelPrivate.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 9/28/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSCreateCardSnapshotModel.h"
#import "VSSCanonicalSerializable.h"
#import "VSSCanonicalDeserializable.h"
#import "VSSSerializable.h"
#import "VSSDeserializable.h"

@interface VSSCreateCardSnapshotModel () <VSSSerializable, VSSDeserializable, VSSCanonicalSerializable, VSSCanonicalDeserializable>

+ (instancetype __nonnull)createCardSnapshotModelWithIdentity:(NSString * __nonnull)identity identityType:(NSString * __nonnull)identityType scope:(VSSCardScope)scope publicKey:(NSData * __nonnull)publicKey data:(NSDictionary<NSString *, NSString *> * __nullable)data;

- (instancetype __nonnull)initWithIdentity:(NSString * __nonnull)identity identityType:(NSString * __nonnull)identityType scope:(VSSCardScope)scope publicKey:(NSData * __nonnull)publicKey data:(NSDictionary<NSString *, NSString *> * __nullable)data info:(NSDictionary<NSString *, NSString *> * __nonnull)info;

+ (instancetype __nonnull)createCardSnapshotModelWithIdentity:(NSString * __nonnull)identity identityType:(NSString * __nonnull)identityType publicKey:(NSData * __nonnull)publicKey data:(NSDictionary<NSString *, NSString *> * __nullable)data;
+ (instancetype __nonnull)createCardSnapshotModelWithIdentity:(NSString * __nonnull)identity identityType:(NSString * __nonnull)identityType publicKey:(NSData * __nonnull)publicKey;

@end
