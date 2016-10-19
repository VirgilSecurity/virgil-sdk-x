//
//  VSSRevokeCard.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 10/6/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSSignedData.h"
#import "VSSModelCommons.h"
#import "VSSRevokeCardData.h"

@interface VSSRevokeCard : VSSSignedData

@property (nonatomic, copy, readonly) VSSRevokeCardData * __nonnull data;

+ (instancetype __nonnull)revokeCardWithCardId:(NSString * __nonnull)cardId reason:(VSSCardRevocationReason)reason;

- (instancetype __nonnull)initWithSignatures:(NSDictionary<NSString *, NSData *> * __nullable)signatures cardVersion:(NSString * __nullable)cardVersion createdAt:(NSDate * __nullable)createdAt NS_UNAVAILABLE;

@end
