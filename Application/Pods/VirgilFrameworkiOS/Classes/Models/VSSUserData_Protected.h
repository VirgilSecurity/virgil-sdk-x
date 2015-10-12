//
//  VSSUserData_Protected.h
//  VirgilFramework
//
//  Created by Pavel Gorb on 9/7/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import "VSSUserData.h"

@interface VSSUserData ()

@property (nonatomic, assign, readwrite) VSSUserDataClass dataClass;
@property (nonatomic, assign, readwrite) VSSUserDataType dataType;
@property (nonatomic, copy, readwrite) NSString * __nonnull value;

@end
