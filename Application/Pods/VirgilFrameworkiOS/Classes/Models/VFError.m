//
//  VFError.m
//  VirgilFramework
//
//  Created by Pavel Gorb on 9/12/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import "VFError.h"
#import "NSObject+VFUtils.h"

NSInteger const kVirgilNoError = 0;

NSString *const kVirgilServiceErrorDomain = @"VirgilServiceErrorDomain";
NSString *const kVirgilServiceUnknownError = @"Virgil service unknown error.";

static NSString *const kVirgilErrorKey = @"error";
static NSString *const kVirgilErrorCode = @"code";

@interface VFError ()

@property (nonatomic, assign, readwrite) NSInteger code;

@end

@implementation VFError

@synthesize code = _code;

#pragma mark - Lifecycle

- (instancetype)initWithCode:(NSInteger)code {
    self = [super init];
    if (self == nil) {
        return nil;
    }
    
    _code = code;
    return self;
}

- (instancetype)init {
    return [self initWithCode:kVirgilNoError];
}

#pragma mark - Class logic

- (NSString *)message {
    if (self.code == kVirgilNoError) {
        return nil;
    }
    return kVirgilServiceUnknownError;
}

- (NSError *)nsError {
    if (self.code == kVirgilNoError) {
        return nil;
    }

    NSString *descr = [self message];
    if (descr == nil) {
        descr = kVirgilServiceUnknownError;
    }
    
    return [NSError errorWithDomain:kVirgilServiceErrorDomain code:self.code userInfo:@{ NSLocalizedDescriptionKey : descr }];
}

#pragma mark - Overrides

- (NSNumber *)isValid {
    return [NSNumber numberWithBool:(self.code != kVirgilNoError)];
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone {
    return [[[self class] alloc] initWithCode:self.code];
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    NSInteger code = [aDecoder decodeIntegerForKey:kVirgilErrorCode];
    return [self initWithCode:code];
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeInteger:self.code forKey:kVirgilErrorCode];
}

#pragma mark - VFSerialization

+ (instancetype)deserializeFrom:(NSDictionary *)candidate {
    NSDictionary *codeObj = [candidate[kVirgilErrorKey] as:[NSDictionary class]];
    NSNumber *code = [codeObj[kVirgilErrorCode] as:[NSNumber class]];

    return [[self alloc] initWithCode:[code integerValue]];
}

@end
