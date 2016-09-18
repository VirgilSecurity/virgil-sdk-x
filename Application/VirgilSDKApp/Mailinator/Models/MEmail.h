//
//  MEmail.h
//  VirgilKeys
//
//  Created by Pavel Gorb on 9/23/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VSSModel.h"

@class MEmailMetadata;
@class MPart;

@interface MEmail : VSSModel

@property (nonatomic, strong, readonly) MEmailMetadata * __nonnull metadata;
@property (nonatomic, strong, readonly) NSDictionary * __nonnull headers;
@property (nonatomic, strong, readonly) NSArray <MPart *>* __nonnull parts;

- (instancetype __nonnull)initWithMetadata:(MEmailMetadata * __nonnull )metadata headers:(NSDictionary * __nonnull )headers parts:(NSArray <MPart *>* __nonnull )parts NS_DESIGNATED_INITIALIZER;

@end
