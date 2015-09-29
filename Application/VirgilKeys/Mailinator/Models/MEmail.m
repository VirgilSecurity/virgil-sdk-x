//
//  MEmail.m
//  VirgilKeys
//
//  Created by Pavel Gorb on 9/23/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import "MEmail.h"
#import "MEmailMetadata.h"
#import "MPart.h"

#import <VirgilFrameworkiOS/NSObject+VFUtils.h>

static NSString *const kMEMetadata = @"metadata";
static NSString *const kMEHeaders = @"headers";
static NSString *const kMEParts = @"parts";

@interface MEmail ()

@property (nonatomic, strong, readwrite) MEmailMetadata *metadata;
@property (nonatomic, strong, readwrite) NSDictionary *headers;
@property (nonatomic, strong, readwrite) NSArray *parts;

@end

@implementation MEmail

@synthesize metadata = _metadata;
@synthesize headers = _headers;
@synthesize parts = _parts;

#pragma mark - Lifecycle

- (instancetype)initWithMetadata:(MEmailMetadata *)metadata headers:(NSDictionary *)headers parts:(NSArray *)parts {
    self = [super init];
    if (self == nil) {
        return nil;
    }
    
    _metadata = metadata;
    _headers = headers;
    _parts = parts;
    return self;
}

- (instancetype)init {
    return [self initWithMetadata:nil headers:nil parts:nil];
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone {
    return [self initWithMetadata:[self.metadata copy] headers:[self.headers copy] parts:[self.parts copy]];
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    MEmailMetadata *metadata = [[aDecoder decodeObjectForKey:kMEMetadata] as:[MEmailMetadata class]];
    NSDictionary *headers = [[aDecoder decodeObjectForKey:kMEHeaders] as:[NSDictionary class]];
    NSArray *parts = [[aDecoder decodeObjectForKey:kMEParts] as:[NSArray class]];
    
    return [self initWithMetadata:metadata headers:headers parts:parts];
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    
    if (self.metadata != nil) {
        [aCoder encodeObject:self.metadata forKey:kMEMetadata];
    }
    if (self.headers != nil) {
        [aCoder encodeObject:self.headers forKey:kMEHeaders];
    }
    if (self.parts != nil) {
        [aCoder encodeObject:self.parts forKey:kMEParts];
    }
}

#pragma mark - VFSerializable

+ (instancetype)deserializeFrom:(NSDictionary *)candidate {
    MEmailMetadata *metadata = [MEmailMetadata deserializeFrom:candidate];
    NSDictionary *headers = [candidate[kMEHeaders] as:[NSDictionary class]];

    NSArray *partsCandidates = [candidate[kMEParts] as:[NSArray class]];
    NSMutableArray *parts = [[NSMutableArray alloc] initWithCapacity:[partsCandidates count]];
    for (NSDictionary *partCandidate in partsCandidates) {
        MPart *part = [MPart deserializeFrom:partCandidate];
        if (part != nil) {
            [parts addObject:part];
        }
    }
    
    if (parts.count == 0) {
        parts = nil;
    }
    
    return [[self alloc] initWithMetadata:metadata headers:headers parts:parts];
}

#pragma mark - Overrides

- (NSNumber *)isValid {
    return @([[self.metadata isValid] boolValue] && (self.parts.count > 0));
}

@end
