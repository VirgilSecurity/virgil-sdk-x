//
//  VSSSerializable.h
//  VirgilSDK
//
//  Created by Pavel Gorb on 9/7/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol VSSDeserializable <NSObject>

- (instancetype __nullable)initWithDict:(NSDictionary * __nonnull)candidate;

@end
