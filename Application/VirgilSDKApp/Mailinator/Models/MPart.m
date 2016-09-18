//
//  MPart.m
//  VirgilKeys
//
//  Created by Pavel Gorb on 9/23/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import "MPart.h"
#import "NSObject+VSSUtils.h"

static NSString *const kMPHeaders = @"headers";
static NSString *const kMPBody = @"body";

@interface MPart ()

@property (nonatomic, strong, readwrite) NSDictionary * __nonnull headers;
@property (nonatomic, strong, readwrite) NSString * __nonnull body;

@end

@implementation MPart

@synthesize headers = _headers;
@synthesize body = _body;

#pragma mark - Lifecycle

- (instancetype)initWithHeaders:(NSDictionary *)headers body:(NSString *)body {
    self = [super init];
    if (self == nil) {
        return nil;
    }
    
    _headers = headers;
    _body = body;
    return self;
}

- (instancetype)init {
    return [self initWithHeaders:@{} body:@""];
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone {
    return [self initWithHeaders:[self.headers copy] body:[self.body copy]];
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    NSDictionary *headers = [[aDecoder decodeObjectForKey:kMPHeaders] as:[NSDictionary class]];
    NSString *body = [[aDecoder decodeObjectForKey:kMPBody] as:[NSString class]];
    
    return [self initWithHeaders:headers body:body];
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    
    if (self.headers != nil) {
        [aCoder encodeObject:self.headers forKey:kMPHeaders];
    }
    if (self.body != nil) {
        [aCoder encodeObject:self.body forKey:kMPBody];
    }
}

#pragma mark - VFSerializable

+ (instancetype)deserializeFrom:(NSDictionary *)candidate {
    NSDictionary *headers = [candidate[kMPHeaders] as:[NSDictionary class]];
    NSString *body = [candidate[kMPBody] as:[NSString class]];
    
    return [[self alloc] initWithHeaders:headers body:body];
}

@end
