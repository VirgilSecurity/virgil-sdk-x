//
//  VSSSearchCardsCriteriaPrivate.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 10/7/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSSearchCardsCriteria.h"
#import "VSSSerializable.h"

@interface VSSSearchCardsCriteria () <VSSSerializable>

- (instancetype __nonnull)initWithScope:(VSSCardScope)scope identityType:(NSString * __nullable)identityType identities:(NSArray<NSString *>* __nonnull)indentities;

@end
