//
//  VSSCardResponse.m
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 10/27/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSCardResponse.h"
#import "VSSModelKeys.h"
#import "VSSCreateCardSnapshotModelPrivate.h"
#import "VSSCardPrivate.h"
#import "NSObject+VSSUtils.h"

@implementation VSSCardResponse

- (VSSCard *)buildCard {
    return [[VSSCard alloc] initWithIdentifier:self.identifier identity:self.model.identity identityType:self.model.identityType publicKey:self.model.publicKey scope:self.model.scope data:self.model.data info:self.model.info createdAt:self.createdAt cardVersion:self.cardVersion];
}

#pragma mark - VSSDeserializable

- (instancetype)initWithDict:(NSDictionary *)candidate {
    self = [super init];

    if (self) {
        NSString *snapshotStr = [candidate[kVSSModelContentSnapshot] as:[NSString class]];
        if (snapshotStr.length == 0)
            return nil;

        NSData *snapshot = [[NSData alloc] initWithBase64EncodedString:snapshotStr options:0];
        if (snapshot.length == 0)
            return nil;

        _snapshot = snapshot;
        
        VSSCreateCardSnapshotModel *model = [VSSCreateCardSnapshotModel createFromCanonicalForm:self.snapshot];
        if (model == nil)
            return nil;
        _model = model;

        NSString *identifier = [candidate[kVSSModelId] as:[NSString class]];
        if (identifier.length > 0)
            _identifier = [identifier copy];

        NSDictionary *metaCandidate = [candidate[kVSSModelMeta] as:[NSDictionary class]];
        if (metaCandidate.count == 0)
            return nil;

        NSMutableDictionary *signaturesDict = [[NSMutableDictionary alloc] init];
        NSDictionary *signatures = [metaCandidate[kVSSModelSigns] as:[NSDictionary class]];
        for (NSString *key in signatures.allKeys) {
            signaturesDict[key] = [[NSData alloc] initWithBase64EncodedString:signatures[key] options:0];
        }
        _signatures = signaturesDict;

        NSDate *createdAt = nil;
        NSString *createdAtStr = [metaCandidate[kVSSModelCreatedAt] as:[NSString class]];
        if (createdAtStr != nil && createdAtStr.length != 0) {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            NSLocale *enUSPOSIXLocale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
            dateFormatter.locale = enUSPOSIXLocale;
            dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZ";
            createdAt = [dateFormatter dateFromString:createdAtStr];
            _createdAt = createdAt;
        }

        NSString *cardVersion = [metaCandidate[kVSSModelCardVersion] as:[NSString class]];
        if (cardVersion.length > 0) {
            _cardVersion = [cardVersion copy];
        }
    }

    return self;
}

@end
