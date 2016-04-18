//
//  VSSError.h
//  VirgilSDK
//
//  Created by Pavel Gorb on 9/12/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import "VSSModel.h"
#import "VSSModelCommons.h"

@interface VSSError : VSSModel

@property (nonatomic, assign, readonly) NSInteger code;

- (instancetype __nonnull)initWithCode:(NSInteger)code NS_DESIGNATED_INITIALIZER;

- (NSString * __nullable)message;
- (NSError * __nullable)nsError;

@end
