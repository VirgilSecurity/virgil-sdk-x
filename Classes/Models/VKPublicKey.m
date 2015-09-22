//
//  VKPublicKey.m
//  VirgilKeysSDK
//
//  Created by Pavel Gorb on 9/7/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import "VKPublicKey.h"
#import "VKUserData.h"
#import "VKIdBundle.h"
#import "VKModelCommons.h"

#import <VirgilFrameworkiOS/NSObject+VFUtils.h>

@interface VKPublicKey ()

@property (nonatomic, copy, readwrite) NSData *key;
@property (nonatomic, copy, readwrite) NSArray *userDataList;

@end

@implementation VKPublicKey

@synthesize key = _key;
@synthesize userDataList = _userDataList;

#pragma mark - Lifecycle

- (instancetype)initWithIdb:(VKIdBundle *)idb key:(NSData *)key userDataList:(NSArray *)userDataList {
    self = [super initWithIdb:idb];
    if (self == nil) {
        return nil;
    }
    
    _key = [key copy];
    // Deep 1-level copy, because UserDataList just contains VKUserData objects, and they conform to NSCopying protocol.
    _userDataList = [[NSArray alloc] initWithArray:userDataList copyItems:YES];
    return self;
}

- (instancetype)initWithIdb:(VKIdBundle *)idb {
    return [self initWithIdb:idb key:nil userDataList:nil];
}

- (instancetype)initWithPublicKey:(VKPublicKey *)publicKey {
    return [self initWithIdb:publicKey.idb key:publicKey.key userDataList:publicKey.userDataList];
}

- (instancetype)init {
    return [self initWithIdb:nil key:nil userDataList:nil];
}

#pragma mark - NSCopying protocol implementation

- (instancetype)copyWithZone:(NSZone *)zone {
    return [[[self class] alloc] initWithIdb:self.idb key:self.key userDataList:self.userDataList];
}

#pragma mark - NSCoding protocol implementation

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    VKIdBundle *Id = [[aDecoder decodeObjectForKey:kVKModelId] as:[VKIdBundle class]];
    NSData *Key = [[aDecoder decodeObjectForKey:kVKModelPublicKey] as:[NSData class]];
    NSArray *UserDataList = [[aDecoder decodeObjectForKey:kVKModelUserData] as:[NSArray class]];
    
    return [self initWithIdb:idb key:key userDataList:userDataList];
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    
    if (self.key != nil) {
        [aCoder encodeObject:self.key forKey:kVKModelPublicKey];
    }
    if (self.userDataList != nil) {
        [aCoder encodeObject:self.userDataList forKey:kVKModelUserData];
    }
}

#pragma mark - VKSerializable

- (NSDictionary *)serialize {
    NSMutableDictionary *dto = [[NSMutableDictionary alloc] initWithDictionary:[super serialize]];
    
    NSString *encodedKey = [self.key base64EncodedStringWithOptions:0];
    if (encodedKey != nil) {
        dto[kVKModelPublicKey] = encodedKey;
    }

    NSMutableArray *udDto = [[NSMutableArray alloc] initWithCapacity:self.userDataList.count];
    for (VKUserData *ud in self.userDataList) {
        [udDto addObject:[ud serialize]];
    }
    if (udDto.count > 0) {
        dto[kVKModelUserData] = udDto;
    }
    return dto;
}

+ (instancetype)deserializeFrom:(NSDictionary *)candidate {
    NSDictionary *idBundle = [candidate[kVKModelId] as:[NSDictionary class]];
    VKIdBundle *idb = [VKIdBundle deserializeFrom:idBundle];

    NSString *encodedKey = [candidate[kVKModelPublicKey] as:[NSString class]];
    NSData *key = [[NSData alloc] initWithBase64EncodedString:encodedKey options:0];
    
    NSArray *udlist = [candidate[kVKModelUserData] as:[NSArray class]];
    NSMutableArray *userDataList = [[NSMutableArray alloc] initWithCapacity:udlist.count];
    for (NSDictionary *udCandidate in udlist) {
        [userDataList addObject:[VKUserData deserializeFrom:udCandidate]];
    }
    if (userDataList.count == 0) {
        userDataList = nil;
    }
    
    return [[self alloc] initWithIdb:idb key:key userDataList:userDataList];
}

#pragma mark - NSObject protocol implementation: equality checks

- (BOOL)isEqual:(id)object {
    VKPublicKey *pk = [object as:[VKPublicKey class]];
    if (pk == nil) {
        return NO;
    }
    
    return ([self.idb isEqual:pk.idb]);
}

- (NSUInteger)hash {
    return [self.idb hash];
}

#pragma mark - Overrides 

- (NSNumber *)isValid {
    return [NSNumber numberWithBool:( (self.idb.publicKeyId != nil) && (self.key.length > 0) )];
}

@end
