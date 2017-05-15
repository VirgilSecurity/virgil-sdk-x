//
//  VSSSignableRequest.m
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 9/23/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VSSSignableRequestPrivate.h"
#import "VSSModelKeys.h"
#import "NSObject+VSSUtils.h"

@implementation VSSSignableRequest

- (instancetype)initWithSnapshot:(NSData *)snapshot snapshotModel:(VSSSnapshotModel *)model signatures:(NSDictionary<NSString *, NSData *> *)signatures {
    self = [super init];
    if (self) {
        _snapshot = [snapshot copy];
        _snapshotModel = model;
        
        if (signatures != nil)
            _signatures = [[NSDictionary alloc] initWithDictionary:signatures copyItems:YES];
        else
            _signatures = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

+ (VSSSnapshotModel * __nullable)buildSnapshotModelFromSnapshot:(NSData * __nonnull)snapshot {
    NSAssert(NO, @"Subclasses must override this method");
    return nil;
}

- (instancetype)initWithSnapshot:(NSData *)snapshot signatures:(NSDictionary<NSString *,NSData *> *)signatures {
    VSSSnapshotModel *model = [self.class buildSnapshotModelFromSnapshot:snapshot];
    return [self initWithSnapshot:snapshot snapshotModel:model signatures:signatures];
}

- (instancetype)initWithSnapshotModel:(VSSSnapshotModel *)model signatures:(NSDictionary<NSString *,NSData *> *)signatures {
    NSData *snapshot = [model getCanonicalForm];
    return [self initWithSnapshot:snapshot snapshotModel:model signatures:signatures];
}

- (instancetype)initWithSnapshot:(NSData *)snapshot snapshotModel:(VSSSnapshotModel *)model {
    return [self initWithSnapshot:snapshot snapshotModel:model signatures:nil];
}

- (instancetype)initWithSnapshot:(NSData * __nonnull)snapshot {
    return [self initWithSnapshot:snapshot signatures:nil];
}

- (instancetype)initWithSnapshotModel:(VSSSnapshotModel *)model {
    return [self initWithSnapshotModel:model signatures:nil];
}

- (BOOL)addSignature:(NSData *)signature forFingerprint:(NSString *)fingerprint {
    ((NSMutableDictionary *)_signatures)[fingerprint] = signature;
    return YES;
}

- (NSDictionary *)serialize {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *metaDict = [[NSMutableDictionary alloc] init];

    NSMutableDictionary *signaturesDict = [[NSMutableDictionary alloc] init];
    for (NSString *key in self.signatures.allKeys) {
        signaturesDict[key] = [((NSData *)self.signatures[key]) base64EncodedStringWithOptions:0];
    }
    
    metaDict[kVSSCModelSigns] = signaturesDict;
    dict[kVSSCModelMeta] = metaDict;
    
    dict[kVSSCModelContentSnapshot] = [self.snapshot base64EncodedStringWithOptions:0];

    return dict;
}

- (instancetype)initWithDict:(NSDictionary *)candidate {
    NSString *snapshotStr = [candidate[kVSSCModelContentSnapshot] vss_as:[NSString class]];
    if (snapshotStr.length == 0)
        return nil;
    
    NSData *snapshot = [[NSData alloc] initWithBase64EncodedString:snapshotStr options:0];
    if (snapshot.length == 0)
        return nil;
    
    NSMutableDictionary<NSString *,NSData *> *signatures = [[NSMutableDictionary alloc] init];;
    NSDictionary *metaDict = [candidate[kVSSCModelMeta] vss_as:[NSDictionary class]];
    if (metaDict.count != 0) {
        NSDictionary<NSString *,NSString *> *signaturesDict = [metaDict[kVSSCModelSigns] vss_as:[NSDictionary class]];
        for (NSString *key in signaturesDict.allKeys) {
            signatures[key] = [[NSData alloc] initWithBase64EncodedString:signaturesDict[key] options:0];
        }
    }
    
    return [self initWithSnapshot:snapshot signatures:signatures];
}

- (instancetype)initWithData:(NSString *)data {
    NSData *jsonData = [[NSData alloc] initWithBase64EncodedString:data options:0];
    
    NSError *error;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
    
    if (error != nil || dict == nil)
        return nil;

    return [[self.class alloc] initWithDict:dict];
}

- (NSString *)exportData {
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:[self serialize] options:0 error:nil];
    return [jsonData base64EncodedStringWithOptions:0];
}

@end
