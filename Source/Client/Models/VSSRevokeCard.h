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

/**
 Virgil Model used for revocation of Virgil Cards.
 See VSSCard. See VSSClient protocol.
 */
@interface VSSRevokeCard : VSSSignedData

/**
 VSSRevokeCardData instance with all info. See VSSRevokeCardData
 */
@property (nonatomic, copy, readonly) VSSRevokeCardData * __nonnull data;

/**
 Factory method which allocates and initalized VSSRevokeCard instance.
 
 @param cardId VSSCard unique id. See VSSCard
 @param reason Revocation reason. See VSSCardRevocationReason

 @return allocated and initialized VSSRevokeCard instance
 */
+ (instancetype __nonnull)revokeCardWithCardId:(NSString * __nonnull)cardId reason:(VSSCardRevocationReason)reason;

/**
 Unavailable initializer inherited from VSSSignedData.
 */
- (instancetype __nonnull)initWithSignatures:(NSDictionary<NSString *, NSData *> * __nullable)signatures cardVersion:(NSString * __nullable)cardVersion createdAt:(NSDate * __nullable)createdAt NS_UNAVAILABLE;

@end
