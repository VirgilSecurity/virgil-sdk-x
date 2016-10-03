//
//  VSSSearchCardsCriteria.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 9/22/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSModelCommons.h"
#import "VSSBaseModel.h"

@interface VSSSearchCardsCriteria : VSSBaseModel

@property (nonatomic, readonly) VSSCardScope scope;
@property (nonatomic, copy, readonly) NSString * __nonnull identityType;
@property (nonatomic, copy, readonly) NSArray<NSString *>* __nonnull identities;

- (instancetype __nonnull)initWithScope:(VSSCardScope)scope identityType:(NSString * __nonnull)identityType identities:(NSArray<NSString *>* __nonnull)indentities;

@end
