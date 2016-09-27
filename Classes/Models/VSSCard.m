//
//  VSSCard.m
//  VirgilKeys
//
//  Created by Pavel Gorb on 1/22/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSPublicKey.h"
#import "VSSCard.h"
#import "VSSIdentity.h"
#import "VSSPublicKey.h"
#import "VSSModelCommons.h"
#import "NSObject+VSSUtils.h"

@interface VSSCard ()

@end

@implementation VSSCard

#pragma mark - Lifecycle

- (instancetype)initWithCardData:(VSSCardData *)cardData metaData:(VSSCardMetaData *)metaData {
    self = [super init];
    if (self) {
        _cardData = cardData;
        _metaData = metaData;
    }
    return self;
}

#pragma mark - VSSSerializable

- (NSDictionary * __nonnull)serialize {
    NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
    
    dict[kVSSModelContentSnapshot] = [self.cardData getCanonicalForm];
    dict[kVSSModelMeta] = [self.metaData serialize];
    
    return dict;
}

#pragma mark - VSSDeserializable

+ (instancetype)deserializeFrom:(NSDictionary *)candidate {
    NSString *contentSnapshotStr = [candidate[kVSSModelContentSnapshot] as:[NSString class]];
    if (contentSnapshotStr == nil || [contentSnapshotStr length] == 0)
        return nil;
    
    VSSCardData *cardData = [VSSCardData createFromCanonicalForm:contentSnapshotStr];
    
    if (cardData == nil)
        return nil;
    
    NSDictionary *metaDict = [candidate[kVSSModelMeta] as:[NSDictionary class]];
    if (metaDict == nil || [metaDict count] == 0)
        return nil;
    
    VSSCardMetaData *metaData = [VSSCardMetaData deserializeFrom:metaDict];
    
    if (metaData == nil)
        return nil;
    
    return [[VSSCard alloc] initWithCardData:cardData metaData:metaData];
}

#pragma mark - VSSCanonicalRepresentable

+ (instancetype __nullable)createFromCanonicalForm:(NSString * __nonnull)canonicalForm {
    NSData *jsonData = [canonicalForm dataUsingEncoding:NSUTF8StringEncoding];
    NSError *parseError;
    NSObject *candidate = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&parseError];
    
    if (parseError != nil)
        return nil;
    
    if ([candidate isKindOfClass:[NSDictionary class]])
        return [VSSCard deserializeFrom:(NSDictionary *)candidate];
    
    return nil;
}

- (NSString * __nonnull)getCanonicalForm {
    NSData *JSONData = [NSJSONSerialization dataWithJSONObject:[self serialize] options:0 error:nil];
    NSString *base64EncodedJSONString = [JSONData base64EncodedStringWithOptions:0];
    
    return base64EncodedJSONString;
}

@end
