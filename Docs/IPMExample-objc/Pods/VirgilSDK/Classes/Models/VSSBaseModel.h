//
//  VSSBaseModel.h
//  VirgilSDK
//
//  Created by Pavel Gorb on 9/11/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import "VSSModel.h"
#import "VSSModelTypes.h"

@interface VSSBaseModel : VSSModel

@property (nonatomic, copy, readonly) GUID * __nonnull Id;
@property (nonatomic, copy, readonly) NSDate * __nullable createdAt;

- (instancetype __nonnull)initWithId:(GUID * __nonnull)Id createdAt:(NSDate * __nullable)createdAt NS_DESIGNATED_INITIALIZER;

@end
