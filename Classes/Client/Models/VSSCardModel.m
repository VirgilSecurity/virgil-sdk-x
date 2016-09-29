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

- (instancetype)initWithSnapshot:(NSString *)snapshot signatures:(NSDictionary *)signatures cardVersion:(NSString *)cardVersion createdAt:(NSDate *)createdAt {
    self = [super initWithSignatures:signatures cardVersion:cardVersion createdAt:createdAt];
    if (self) {
        _snapshot = [snapshot copy];
        _data = [VSSCardData createFromCanonicalForm:snapshot];
    }
    
    return self;
}

- (instancetype)initWithSnapshot:(NSString *)snapshot {
    return [self initWithSnapshot:snapshot signatures:nil cardVersion:nil createdAt:nil];
}

#pragma mark - VSSSerializable

- (NSDictionary * __nonnull)serialize {
    NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
    
    dict[kVSSModelContentSnapshot] = self.snapshot;
    dict[kVSSModelMeta] = [super serialize];
    
    return dict;
}

#pragma mark - VSSDeserializable

+ (instancetype)deserializeFrom:(NSDictionary *)candidate {
    NSDictionary *signedDict = [candidate[kVSSModelMeta] as:[NSDictionary class]];
    if (signedDict == nil || [signedDict count] == 0)
        return nil;
    
    VSSSignedData *signedData = [super deserializeFrom:signedDict];
    if (signedData == nil)
        return nil;
    
    NSString *snapshot = [candidate[kVSSModelContentSnapshot] as:[NSString class]];
    if (snapshot == nil || [snapshot length] == 0)
        return nil;
    
    return [[VSSCardModel alloc] initWithSnapshot:snapshot signatures:signedData.signatures cardVersion:signedData.cardVersion createdAt:signedData.createdAt];
}

@end
