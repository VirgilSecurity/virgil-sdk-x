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

@property (nonatomic, copy, readwrite) NSData *Key;
@property (nonatomic, copy, readwrite) NSArray *UserDataList;

@end

@implementation VKPublicKey

@synthesize Key = _Key;
@synthesize UserDataList = _UserDataList;

#pragma mark - Lifecycle

- (instancetype)initWithId:(VKIdBundle *)Id Key:(NSData *)Key UserDataList:(NSArray *)UserDataList {
    self = [super initWithId:Id];
    if (self == nil) {
        return nil;
    }
    
    _Key = [Key copy];
    // Deep 1-level copy, because UserDataList just contains VKUserData objects, and they conform to NSCopying protocol.
    _UserDataList = [[NSArray alloc] initWithArray:UserDataList copyItems:YES];
    return self;
}

- (instancetype)initWithId:(VKIdBundle *)Id {
    return [self initWithId:Id Key:nil UserDataList:nil];
}

- (instancetype)initWithPublicKey:(VKPublicKey *)publicKey {
    return [self initWithId:publicKey.Id Key:publicKey.Key UserDataList:publicKey.UserDataList];
}

- (instancetype)init {
    return [self initWithId:nil Key:nil UserDataList:nil];
}

#pragma mark - NSCopying protocol implementation

- (instancetype)copyWithZone:(NSZone *)zone {
    return [[[self class] alloc] initWithId:self.Id Key:self.Key UserDataList:self.UserDataList];
}

#pragma mark - NSCoding protocol implementation

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    VKIdBundle *Id = [[aDecoder decodeObjectForKey:kVKModelId] as:[VKIdBundle class]];
    NSData *Key = [[aDecoder decodeObjectForKey:kVKModelPublicKey] as:[NSData class]];
    NSArray *UserDataList = [[aDecoder decodeObjectForKey:kVKModelUserData] as:[NSArray class]];
    
    return [self initWithId:Id Key:Key UserDataList:UserDataList];
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    
    if (self.Key != nil) {
        [aCoder encodeObject:self.Key forKey:kVKModelPublicKey];
    }
    if (self.UserDataList != nil) {
        [aCoder encodeObject:self.UserDataList forKey:kVKModelUserData];
    }
}

#pragma mark - VKSerializable

- (NSDictionary *)serialize {
    NSMutableDictionary *dto = [[NSMutableDictionary alloc] initWithDictionary:[super serialize]];
    
    NSString *encodedKey = [self.Key base64EncodedStringWithOptions:0];
    if (encodedKey != nil) {
        dto[kVKModelPublicKey] = encodedKey;
    }

    NSMutableArray *udDto = [[NSMutableArray alloc] initWithCapacity:self.UserDataList.count];
    for (VKUserData *ud in self.UserDataList) {
        [udDto addObject:[ud serialize]];
    }
    if (udDto.count > 0) {
        dto[kVKModelUserData] = udDto;
    }
    return dto;
}

+ (instancetype)deserializeFrom:(NSDictionary *)candidate {
    NSDictionary *idBundle = [candidate[kVKModelId] as:[NSDictionary class]];
    VKIdBundle *Id = [VKIdBundle deserializeFrom:idBundle];

    NSString *encodedKey = [candidate[kVKModelPublicKey] as:[NSString class]];
    NSData *Key = [[NSData alloc] initWithBase64EncodedString:encodedKey options:0];
    
    NSArray *udlist = [candidate[kVKModelUserData] as:[NSArray class]];
    NSMutableArray *UserDataList = [[NSMutableArray alloc] initWithCapacity:udlist.count];
    for (NSDictionary *udCandidate in udlist) {
        [UserDataList addObject:[VKUserData deserializeFrom:udCandidate]];
    }
    if (UserDataList.count == 0) {
        UserDataList = nil;
    }
    
    return [[self alloc] initWithId:Id Key:Key UserDataList:UserDataList];
}

#pragma mark - NSObject protocol implementation: equality checks

- (BOOL)isEqual:(id)object {
    VKPublicKey *pk = [object as:[VKPublicKey class]];
    if (pk == nil) {
        return NO;
    }
    
    return ([self.Id isEqual:pk.Id]);
}

- (NSUInteger)hash {
    return [self.Id hash];
}

#pragma mark - Overrides 

- (NSNumber *)isValid {
    return [NSNumber numberWithBool:( (self.Id.publicKeyId != nil) && (self.Key.length > 0) )];
}

@end
