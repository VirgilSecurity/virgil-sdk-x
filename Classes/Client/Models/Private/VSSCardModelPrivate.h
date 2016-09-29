//
//  VSSCardModelPrivate.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 9/29/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSCardModel.h"
#import "VSSSignedData.h"
#import "VSSSignedDataPrivate.h"

@interface VSSCardModel () <VSSSerializable, VSSDeserializable>

@property (nonatomic, copy) NSString * __nonnull snapshot;

- (instancetype __nonnull)initWithSnapshot:(NSString * __nonnull)snapshot;

- (instancetype __nonnull)initWithSnapshot:(NSString * __nonnull)snapshot signatures:(NSDictionary * __nullable)signatures cardVersion:(NSString * __nullable)cardVersion createdAt:(NSDate * __nullable)createdAt NS_DESIGNATED_INITIALIZER;

@end
