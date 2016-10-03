//
//  VSSCardModel.m
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 9/29/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VSSCardModel.h"
#import "VSSCardModelPrivate.h"
#import "VSSSignedDataPrivate.h"
#import "VSSCardDataPrivate.h"
#import "VSSModelKeys.h"
#import "NSObject+VSSUtils.h"

@implementation VSSCardModel

+ (instancetype)createWithIdentity:(NSString *)identity identityType:(NSString *)identityType publicKey:(NSData *)publicKey data:(NSDictionary *)data {
    VSSCardData *cardData = [VSSCardData createWithIdentity:identity identityType:identityType publicKey:publicKey data:data];
    return [[VSSCardModel alloc] initWithCardData:cardData];
}

+ (instancetype)createWithIdentity:(NSString *)identity identityType:(NSString *)identityType publicKey:(NSData *)publicKey {
    return [VSSCardModel createWithIdentity:identity identityType:identityType publicKey:publicKey data:nil];
}

+ (instancetype)createGlobalWithIdentity:(NSString *)identity publicKey:(NSData *)publicKey data:(NSDictionary *)data {
    VSSCardData *cardData = [VSSCardData createGlobalWithIdentity:identity publicKey:publicKey data:data];
    return [[VSSCardModel alloc] initWithCardData:cardData];
}

+ (instancetype)createGlobalWithIdentity:(NSString *)identity publicKey:(NSData *)publicKey {
    return [VSSCardModel createGlobalWithIdentity:identity publicKey:publicKey data:nil];
}

- (instancetype)initWithSnapshot:(NSData *)snapshot cardData:(VSSCardData *)cardData signatures:(NSDictionary *)signatures cardVersion:(NSString *)cardVersion createdAt:(NSDate *)createdAt {
    self = [super initWithSignatures:signatures cardVersion:cardVersion createdAt:createdAt];
    if (self) {
        _snapshot = [snapshot copy];
        _data = cardData;
    }
    
    return self;
}

- (instancetype)initWithSnapshot:(NSData *)snapshot cardData:(VSSCardData *)cardData {
    return [self initWithSnapshot:snapshot cardData:cardData signatures:nil cardVersion:nil createdAt:nil];
}

- (instancetype)initWithCardData:(VSSCardData *)cardData signatures:(NSDictionary *)signatures cardVersion:(NSString *)cardVersion createdAt:(NSDate *)createdAt {
    NSData *snapshot = [cardData getCanonicalForm];
    return [self initWithSnapshot:snapshot cardData:cardData signatures:signatures cardVersion:cardVersion createdAt:createdAt];
}

- (instancetype)initWithCardData:(VSSCardData *)cardData {
    return [self initWithCardData:cardData signatures:nil cardVersion:nil createdAt:nil];
}

- (instancetype)initWithSnapshot:(NSData *)snapshot signatures:(NSDictionary *)signatures cardVersion:(NSString *)cardVersion createdAt:(NSDate *)createdAt {
    VSSCardData *cardData = [VSSCardData createFromCanonicalForm:snapshot];
    return [self initWithSnapshot:snapshot cardData:cardData signatures:signatures cardVersion:cardVersion createdAt:createdAt];
}

- (instancetype)initWithSnapshot:(NSData *)snapshot {
    return [self initWithSnapshot:snapshot signatures:nil cardVersion:nil createdAt:nil];
}


#pragma mark - VSSSerializable

- (NSDictionary * __nonnull)serialize {
    NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
    
    dict[kVSSModelContentSnapshot] = [self.snapshot base64EncodedStringWithOptions:0];
    dict[kVSSModelMeta] = [super serialize];
    
    return dict;
}

#pragma mark - VSSDeserializable

+ (instancetype)deserializeFrom:(NSDictionary *)candidate {
    NSDictionary *signedDict = [candidate[kVSSModelMeta] as:[NSDictionary class]];
    if ([signedDict count] == 0)
        return nil;
    
    VSSSignedData *signedData = [super deserializeFrom:signedDict];
    if (signedData == nil)
        return nil;
    
    NSString *snapshotStr = [candidate[kVSSModelContentSnapshot] as:[NSString class]];
    if ([snapshotStr length] == 0)
        return nil;
    
    NSData *snapshot = [[NSData alloc] initWithBase64EncodedString:snapshotStr options:0];
    if (snapshot == nil)
        return nil;
    
    return [[VSSCardModel alloc] initWithSnapshot:snapshot signatures:signedData.signatures cardVersion:signedData.cardVersion createdAt:signedData.createdAt];
}

@end
