//
//  VSSUserData_Protected.h
//  VirgilFramework
//
//  Created by Pavel Gorb on 9/7/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import "VSSUserData.h"

@interface VSSUserData ()

@property (nonatomic, assign, readwrite) VFUserDataClass dataClass;
@property (nonatomic, assign, readwrite) VFUserDataType dataType;
@property (nonatomic, copy, readwrite) NSString * __nonnull value;

@end
