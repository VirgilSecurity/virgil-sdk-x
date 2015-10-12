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

@interface MEmail : VSSModel

@property (nonatomic, strong, readonly) MEmailMetadata *metadata;
@property (nonatomic, strong, readonly) NSDictionary *headers;
@property (nonatomic, strong, readonly) NSArray *parts;

- (instancetype)initWithMetadata:(MEmailMetadata *)metadata headers:(NSDictionary *)headers parts:(NSArray *)parts NS_DESIGNATED_INITIALIZER;

@end
