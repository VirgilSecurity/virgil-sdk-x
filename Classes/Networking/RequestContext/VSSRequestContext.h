//
//  VSSRequestContext.h
//  VirgilKeys
//
//  Created by Pavel Gorb on 2/10/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VSSRequestContext : NSObject

@property (nonatomic, strong, readonly) NSString * __nonnull uuid;
@property (nonatomic, strong, readonly) NSString * __nonnull serviceUrl;

- (instancetype __nonnull)initWithServiceUrl:(NSString * __nonnull)serviceUrl NS_DESIGNATED_INITIALIZER;

@end
