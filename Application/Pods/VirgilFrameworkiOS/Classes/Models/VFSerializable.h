//
//  VFSerializable.h
//  VirgilFramework
//
//  Created by Pavel Gorb on 9/7/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol VFSerializable <NSObject>

@required
- (NSDictionary *)serialize;
+ (instancetype)deserializeFrom:(NSDictionary *)candidate;

@end
