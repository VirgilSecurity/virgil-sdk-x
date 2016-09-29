//
//  VSSCardModel.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 9/29/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSSignedData.h"
#import "VSSCardData.h"

@interface VSSCardModel : VSSSignedData

@property (nonatomic, copy, readonly) NSString * __nonnull snapshot;

@property (nonatomic, copy, readonly) VSSCardData * __nonnull data;

- (instancetype __nonnull)initWithSignatures:(NSDictionary * __nullable)signatures cardVersion:(NSString * __nullable)cardVersion createdAt:(NSDate * __nullable)createdAt NS_UNAVAILABLE;

@end
