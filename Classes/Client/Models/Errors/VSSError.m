//
//  VSSError.m
//  VirgilSDK
//
//  Created by Pavel Gorb on 9/12/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import "VSSError.h"
#import "NSObject+VSSUtils.h"
#import "VSSModelKeys.h"
#import "VSSModelCommonsPrivate.h"

@interface VSSError ()

@property (nonatomic, readwrite) NSInteger code;

@end

@implementation VSSError

#pragma mark - Lifecycle

- (instancetype)initWithCode:(NSInteger)code {
    self = [super init];
    if (self == nil) {
        return nil;
    }
    
    _code = code;
    return self;
}

#pragma mark - Class logic

- (NSString *)message {
    if (self.code == kVSSNoErrorValue) {
        return nil;
    }
    return kVSSUnknownError;
}

- (NSError *)nsError {
    if (self.code == kVSSNoErrorValue) {
        return nil;
    }

    NSString *descr = [self message];
    if (descr == nil) {
        descr = kVSSUnknownError;
    }
    
    return [NSError errorWithDomain:kVSSErrorDomain code:self.code userInfo:@{ NSLocalizedDescriptionKey : descr }];
}

#pragma mark - VSSSerialization

+ (instancetype)deserializeFrom:(NSDictionary *)candidate {
    NSNumber *code = [candidate[kVSSModelCode] as:[NSNumber class]];
    if (code == nil)
        return nil;
    
    return [[self alloc] initWithCode:[code integerValue]];
}

@end
