//
//  VFError.h
//  VirgilFramework
//
//  Created by Pavel Gorb on 9/12/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import "VFModel.h"

extern NSInteger const kVirgilNoError;

extern NSString *const kVirgilServiceErrorDomain;
extern NSString *const kVirgilServiceUnknownError;

@interface VFError : VFModel

@property (nonatomic, assign, readonly) NSInteger code;

- (instancetype)initWithCode:(NSInteger)code NS_DESIGNATED_INITIALIZER;

- (NSString *)message;
- (NSError *)nsError;

@end
