//
//  VSSSearchCardsCriteria.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 9/22/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSModelCommons.h"
#import "VSSBaseModel.h"

/**
 Virgil Model representing Search Criteria while searching for Virgil Cards.
 See VSSClient protocol.
 */
@interface VSSSearchCardsCriteria : VSSBaseModel

/**
 VSSCreateCardRequestscope. See VSSCardScope.
 */
@property (nonatomic, readonly) VSSCardScope scope;

/**
 NSString with Identity Type (such as Email, Username, Phone number) which corresponds to desired Virgil Cards.
 */
@property (nonatomic, copy, readonly) NSString * __nonnull identityType;

/**
 Array of Identities within Identity Type for desired Virgil Cards.
 */
@property (nonatomic, copy, readonly) NSArray<NSString *>* __nonnull identities;

/**
 Factory method which allocated and initialized VSSSearchCardsCriteria instance.

 @param scope        VSSCreateCardRequestscope. See VSSCardScope
 @param identityType NSString with Identity Type (such as Email, Username, Phone number)
 @param indentities  Array of Identities within Identity Type for desired Virgil Cards

 @return allocated and initialized VSSSearchCardsCriteria instance
 */
+ (instancetype __nonnull)searchCardsCriteriaWithScope:(VSSCardScope)scope identityType:(NSString * __nullable)identityType identities:(NSArray<NSString *>* __nonnull)indentities;

/**
 Factory method which allocated and initialized VSSSearchCardsCriteria instance.
 
 @param identityType NSString with Identity Type (such as Email, Username, Phone number)
 @param indentities  Array of Identities within Identity Type for desired Virgil Cards
 
 @return allocated and initialized VSSSearchCardsCriteria instance
 */
+ (instancetype __nonnull)searchCardsCriteriaWithIdentityType:(NSString * __nullable)identityType identities:(NSArray<NSString *>* __nonnull)indentities;

/**
 Unavailable no-argument initializer inherited from NSObject
 */
- (instancetype __nonnull)init NS_UNAVAILABLE;

@end
