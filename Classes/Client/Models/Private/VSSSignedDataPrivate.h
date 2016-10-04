//
//  VSSSignedDataPrivate.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 9/28/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSSignedData.h"
#import "VSSSerializable.h"
#import "VSSDeserializable.h"

@interface VSSSignedData () <VSSSerializable, VSSDeserializable>

- (instancetype __nonnull)initWithSnapshot:(NSData * __nonnull)snapshot signatures:(NSDictionary * __nullable)signatures cardVersion:(NSString * __nullable)cardVersion createdAt:(NSDate * __nullable)createdAt;

@end
