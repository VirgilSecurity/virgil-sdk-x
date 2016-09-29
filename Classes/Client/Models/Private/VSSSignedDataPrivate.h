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

- (instancetype __nonnull)initWithSignatures:(NSDictionary * __nullable)signatures cardVersion:(NSString * __nullable)cardVersion createdAt:(NSDate * __nullable)createdAt NS_DESIGNATED_INITIALIZER;

@end
