//
//  VSSMeta.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 9/26/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSRequestData.h"
#import "VSSSigningData.h"
#import "VSSSerializable.h"
#import "VSSDeserializable.h"

@interface VSSCardMetaData : VSSRequestData <VSSSerializable, VSSDeserializable>

@property (nonatomic, copy, readonly) NSDate * __nullable createdAt;
@property (nonatomic, copy, readonly) NSString * __nullable cardVersion;
@property (nonatomic, copy, readonly) VSSSigningData * __nonnull signingData;

- (instancetype __nonnull)initWithSigningData:(VSSSigningData * __nonnull)signingData cardVersion:(NSString * __nullable)cardVersion createdAt:(NSDate * __nullable)createdAt NS_DESIGNATED_INITIALIZER;

- (instancetype __nonnull)init NS_UNAVAILABLE;

@end
