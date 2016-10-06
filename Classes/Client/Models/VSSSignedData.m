//
//  VSSSigningRequestData.m
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 9/23/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VSSSignedData.h"
#import "VSSSignedDataPrivate.h"
#import "VSSModelKeys.h"
#import "NSObject+VSSUtils.h"

@implementation VSSSignedData

- (instancetype)initWithSnapshot:(NSData *)snapshot identifier:(NSString *)identifier signatures:(NSDictionary *)signatures cardVersion:(NSString *)cardVersion createdAt:(NSDate *)createdAt {
    self = [super init];
    if (self) {
        _identifier = [identifier copy];
        _snapshot = [snapshot copy];
        
        if (signatures != nil)
            _signatures = [signatures copy];
        else
            _signatures = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (instancetype)initWithSnapshot:(NSData *)snapshot signatures:(NSDictionary *)signatures cardVersion:(NSString *)cardVersion createdAt:(NSDate *)createdAt {
    return [self initWithSnapshot:snapshot identifier:nil signatures:signatures cardVersion:cardVersion createdAt:createdAt];
}

- (void)addSignature:(NSData *)signature forFingerprint:(NSString *)fingerprint {
    ((NSMutableDictionary *)_signatures)[fingerprint] = signature;
}

- (NSDictionary *)serialize {
    // Doesn't include createdAt, cardVerion and Identifier
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *metaDict = [[NSMutableDictionary alloc] init];

    NSMutableDictionary *signaturesDict = [[NSMutableDictionary alloc] init];
    for (NSString *key in self.signatures.allKeys) {
        signaturesDict[key] = [((NSData *)self.signatures[key]) base64EncodedStringWithOptions:0];
    }
    
    metaDict[kVSSModelSigns] = signaturesDict;
    dict[kVSSModelMeta] = metaDict;
    
    dict[kVSSModelContentSnapshot] = [self.snapshot base64EncodedStringWithOptions:0];

    return dict;
}

- (instancetype)initWithDict:(NSDictionary *)candidate {
    self = [super init];
    
    if (self) {
        NSString *snapshotStr = [candidate[kVSSModelContentSnapshot] as:[NSString class]];
        if ([snapshotStr length] == 0)
            return nil;
        
        NSData *snapshot = [[NSData alloc] initWithBase64EncodedString:snapshotStr options:0];
        if ([snapshot length] == 0)
            return nil;
        
        _snapshot = snapshot;
        
        NSString *identifier = [candidate[kVSSModelId] as:[NSString class]];
        if ([identifier length] == 0)
            return nil;
        
        _identifier = [identifier copy];

        NSDictionary *metaCandidate = [candidate[kVSSModelMeta] as:[NSDictionary class]];
        if ([metaCandidate count] == 0)
            return nil;

        NSMutableDictionary *signaturesDict = [[NSMutableDictionary alloc] init];
        NSDictionary *signatures = [metaCandidate[kVSSModelSigns] as:[NSDictionary class]];
        for (NSString *key in signatures.allKeys) {
            signaturesDict[key] = [[NSData alloc] initWithBase64EncodedString:signatures[key] options:0];
        }
        _signatures = signaturesDict;

        NSDate *createdAt = nil;
        NSString *createdAtStr = [metaCandidate[kVSSModelCreatedAt] as:[NSString class]];
        if (createdAtStr != nil && [createdAtStr length] != 0) {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            NSLocale *enUSPOSIXLocale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
            [dateFormatter setLocale:enUSPOSIXLocale];
            [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
            createdAt = [dateFormatter dateFromString:createdAtStr];
            _createdAt = createdAt;
        }

        NSString *cardVersion = [metaCandidate[kVSSModelCardVersion] as:[NSString class]];
        _cardVersion = [cardVersion copy];
    }

    return self;
}

@end
