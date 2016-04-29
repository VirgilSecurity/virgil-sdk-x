//
//  VSSIdentityInfo.h
//  VirgilSDK
//
//  Created by Pavel Gorb on 4/28/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSModel.h"
#import "VSSModelTypes.h"

@interface VSSIdentityInfo : VSSModel

@property (nonatomic, assign) VSSIdentityType type;
@property (nonatomic, copy) NSString * __nonnull value;
@property (nonatomic, copy) NSString * __nullable validationToken;

- (instancetype __nonnull)initWithType:(VSSIdentityType)type value:(NSString * __nonnull)value validationToken:(NSString * __nullable)validationToken NS_DESIGNATED_INITIALIZER;
- (instancetype __nonnull)Type:(VSSIdentityType)type value:(NSString * __nonnull)value;

- (NSDictionary * __nonnull)asDictionary;

@end
