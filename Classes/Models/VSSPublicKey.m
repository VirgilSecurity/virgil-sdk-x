//
//  VSSPublicKey.m
//  VirgilKeysSDK
//
//  Created by Pavel Gorb on 9/7/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import "VSSPublicKey.h"
#import "VSSUserDataExtended.h"
#import "VSSIdBundle.h"
#import "VSSKeysModelCommons.h"

#import <VirgilFrameworkiOS/VSSUserData.h>
#import <VirgilFrameworkiOS/NSObject+VSSUtils.h>

@interface VSSPublicKey ()

@property (nonatomic, copy, readwrite) NSData * __nonnull key;
@property (nonatomic, copy, readwrite) NSArray * __nonnull userDataList;

@end

@implementation VSSPublicKey

@synthesize key = _key;
@synthesize userDataList = _userDataList;

#pragma mark - Lifecycle

- (instancetype)initWithIdb:(VSSIdBundle *)idb key:(NSData *)key userDataList:(NSArray *)userDataList {
    self = [super initWithIdb:idb];
    if (self == nil) {
        return nil;
    }
    
    _key = [key copy];
    // Deep 1-level copy, because UserDataList just contains VKUserData objects, and they conform to NSCopying protocol.
    _userDataList = [[NSArray alloc] initWithArray:userDataList copyItems:YES];
    return self;
}

- (instancetype)initWithIdb:(VSSIdBundle *)idb {
    return [self initWithIdb:idb key:[NSData data] userDataList:@[]];
}

- (instancetype)initWithKey:(NSData *)key userDataList:(NSArray *)userDataList {
    return [self initWithIdb:[[VSSIdBundle alloc] init] key:key userDataList:userDataList];
}

- (instancetype)init {
    return [self initWithIdb:[[VSSIdBundle alloc] init] key:[NSData data] userDataList:@[]];
}

#pragma mark - NSCopying protocol implementation

- (instancetype)copyWithZone:(NSZone *)zone {
    return [[[self class] alloc] initWithIdb:self.idb key:self.key userDataList:self.userDataList];
}

#pragma mark - NSCoding protocol implementation

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    VSSIdBundle *idb = [[aDecoder decodeObjectForKey:kVSSKeysModelId] as:[VSSIdBundle class]];
    NSData *key = [[aDecoder decodeObjectForKey:kVSSKeysModelPublicKey] as:[NSData class]];
    NSArray *userDataList = [[aDecoder decodeObjectForKey:kVSSKeysModelUserData] as:[NSArray class]];
    
    return [self initWithIdb:idb key:key userDataList:userDataList];
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    
    if (self.key != nil) {
        [aCoder encodeObject:self.key forKey:kVSSKeysModelPublicKey];
    }
    if (self.userDataList != nil) {
        [aCoder encodeObject:self.userDataList forKey:kVSSKeysModelUserData];
    }
}

#pragma mark - VKSerializable

- (NSDictionary *)serialize {
    NSMutableDictionary *dto = [[NSMutableDictionary alloc] initWithDictionary:[super serialize]];
    
    NSString *encodedKey = [self.key base64EncodedStringWithOptions:0];
    if (encodedKey != nil) {
        dto[kVSSKeysModelPublicKey] = encodedKey;
    }

    NSMutableArray *udDto = [[NSMutableArray alloc] initWithCapacity:self.userDataList.count];
    for (VSSUserData *ud in self.userDataList) {
        [udDto addObject:[ud serialize]];
    }
    if (udDto.count > 0) {
        dto[kVSSKeysModelUserData] = udDto;
    }
    return dto;
}

+ (instancetype)deserializeFrom:(NSDictionary *)candidate {
    NSDictionary *idBundle = [candidate[kVSSKeysModelId] as:[NSDictionary class]];
    VSSIdBundle *idb = [VSSIdBundle deserializeFrom:idBundle];

    NSString *encodedKey = [candidate[kVSSKeysModelPublicKey] as:[NSString class]];
    NSData *key = [[NSData alloc] initWithBase64EncodedString:encodedKey options:0];
    
    NSArray *udlist = [candidate[kVSSKeysModelUserData] as:[NSArray class]];
    NSMutableArray *userDataList = [[NSMutableArray alloc] initWithCapacity:udlist.count];
    for (NSDictionary *udCandidate in udlist) {
        [userDataList addObject:[VSSUserDataExtended deserializeFrom:udCandidate]];
    }
    if (userDataList.count == 0) {
        userDataList = nil;
    }
    
    return [[self alloc] initWithIdb:idb key:key userDataList:userDataList];
}

#pragma mark - NSObject protocol implementation: equality checks

- (BOOL)isEqual:(id)object {
    VSSPublicKey *pk = [object as:[VSSPublicKey class]];
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
