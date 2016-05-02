//
//  VSSIdentityInfo.h
//  VirgilSDK
//
//  Created by Pavel Gorb on 4/28/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSModel.h"
#import "VSSModelCommons.h"

@interface VSSIdentityInfo : VSSModel

@property (nonatomic, copy) NSString * __nonnull type;
@property (nonatomic, copy) NSString * __nonnull value;
@property (nonatomic, copy) NSString * __nullable validationToken;

- (instancetype __nonnull)initWithType:(NSString * __nonnull)type value:(NSString * __nonnull)value validationToken:(NSString * __nullable)validationToken NS_DESIGNATED_INITIALIZER;
- (instancetype __nonnull)initWithType:(NSString * __nonnull)type value:(NSString * __nonnull)value;

- (NSDictionary * __nonnull)asDictionary;

@end
