//
//  MPart.h
//  VirgilKeys
//
//  Created by Pavel Gorb on 9/23/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>

@import VirgilSDK;

@interface MPart : NSObject

@property (nonatomic, strong, readonly) NSDictionary * __nonnull headers;
@property (nonatomic, strong, readonly) NSString * __nonnull body;

+ (instancetype __nonnull) deserializeFrom:(NSDictionary * __nonnull)candidate;

- (instancetype __nonnull)initWithHeaders:(NSDictionary * __nonnull )headers body:(NSString * __nonnull )body NS_DESIGNATED_INITIALIZER;

@end
