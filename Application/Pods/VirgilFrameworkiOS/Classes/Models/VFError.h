//
//  VFError.h
//  VirgilFramework
//
//  Created by Pavel Gorb on 9/12/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import "VFModel.h"

extern NSInteger const kVirgilNoError;

extern NSString * __nonnull const kVirgilServiceErrorDomain;
extern NSString * __nonnull const kVirgilServiceUnknownError;

@interface VFError : VFModel

@property (nonatomic, assign, readonly) NSInteger code;

- (instancetype __nonnull)initWithCode:(NSInteger)code NS_DESIGNATED_INITIALIZER;

- (NSString * __nullable)message;
- (NSError * __nullable)nsError;

@end
