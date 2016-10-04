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

- (instancetype)initWithSnapshot:(NSData *)snapshot signatures:(NSDictionary *)signatures cardVersion:(NSString *)cardVersion createdAt:(NSDate *)createdAt {
    self = [super init];
    if (self) {
        _snapshot = [snapshot copy];
        
        if (signatures != nil)
            _signatures = [signatures copy];
        else
            _signatures = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)addSignature:(NSData *)signature forFingerprint:(NSString *)fingerprint {
    ((NSMutableDictionary *)_signatures)[fingerprint] = signature;
}

- (NSDictionary *)serialize {
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

        NSDictionary *metaCandidate = [candidate[kVSSModelMeta] as:[NSDictionary class]];
        if ([metaCandidate count] == 0)
            return nil;

        NSMutableDictionary *signaturesDict = [[NSMutableDictionary alloc] init];
        NSDictionary *signatures = [candidate[kVSSModelSigns] as:[NSDictionary class]];
        for (NSString *key in signatures.allKeys) {
            signaturesDict[key] = [[NSData alloc] initWithBase64EncodedString:signatures[key] options:0];
        }
        _signatures = signaturesDict;

        NSDate *createdAt = nil;
        NSString *createdAtStr = [candidate[kVSSModelCreatedAt] as:[NSString class]];
        if (createdAtStr != nil && [createdAtStr length] != 0) {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            NSLocale *enUSPOSIXLocale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
            [dateFormatter setLocale:enUSPOSIXLocale];
            [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZZ"];
            createdAt = [dateFormatter dateFromString:createdAtStr];
            _createdAt = [createdAt copy];
        }

        NSString *cardVersion = [candidate[kVSSModelCardVersion] as:[NSString class]];
        _cardVersion = [cardVersion copy];
    }

    return self;
}

@end
