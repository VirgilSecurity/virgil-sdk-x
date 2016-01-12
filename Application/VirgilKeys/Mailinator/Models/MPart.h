//
//  MPart.h
//  VirgilKeys
//
//  Created by Pavel Gorb on 9/23/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <VirgilKit/VSSModel.h>

@interface MPart : VSSModel

@property (nonatomic, strong, readonly) NSDictionary *headers;
@property (nonatomic, strong, readonly) NSString* body;

- (instancetype)initWithHeaders:(NSDictionary *)headers body:(NSString *)body NS_DESIGNATED_INITIALIZER;

@end
