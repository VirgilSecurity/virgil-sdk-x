//
//  VSSUserDataExtended.m
//  VirgilKeysSDK
//
//  Created by Pavel Gorb on 9/7/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import "VSSUserDataExtended.h"
#import "VSSIdBundle.h"
#import "VSSKeysModelCommons.h"

#import <VirgilFrameworkiOS/VSSUserData_Protected.h>
#import <VirgilFrameworkiOS/NSObject+VSSUtils.h>

@interface VSSUserDataExtended ()

@property (nonatomic, copy, readwrite) VSSIdBundle * __nonnull idb;
@property (nonatomic, copy, readwrite) NSNumber * __nonnull confirmed;

@end

@implementation VSSUserDataExtended

@synthesize idb = _idb;
@synthesize confirmed = _confirmed;

#pragma mark - Lifecycle

- (instancetype)initWithIdb:(VSSIdBundle *)idb dataClass:(VSSUserDataClass)dataClass dataType:(VSSUserDataType)dataType value:(NSString *)value confirmed:(NSNumber *)confirmed {
    self = [super initWithDataClass:dataClass dataType:dataType value:value];
    if (self == nil) {
        return nil;
    }

    _idb = [idb copy];
    _confirmed = [confirmed copy];
    return self;
}

- (instancetype)initWithDataClass:(VSSUserDataClass)dataClass dataType:(VSSUserDataType)dataType value:(NSString *)value {
    return [self initWithIdb:[[VSSIdBundle alloc] init] dataClass:dataClass dataType:dataType value:value confirmed:@NO];
}

- (instancetype)init {
    return [self initWithIdb:[[VSSIdBundle alloc] init] dataClass:UDCUnknown dataType:UDTUnknown value:@"" confirmed:@NO];
}

#pragma mark - NSCopying protocol implementation

- (instancetype)copyWithZone:(NSZone *)zone {
    return [[[self class] alloc] initWithIdb:self.idb dataClass:self.dataClass dataType:self.dataType value:self.value confirmed:self.confirmed];
}

#pragma mark - NSCoding protocol implementation

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    VSSIdBundle *idb = [[aDecoder decodeObjectForKey:kVSSKeysModelId] as:[VSSIdBundle class]];
    NSNumber *classCandidate = [[aDecoder decodeObjectForKey:kVSSModelClass] as:[NSNumber class]];
    NSNumber *typeCandidate = [[aDecoder decodeObjectForKey:kVSSModelType] as:[NSNumber class]];
    NSString *value = [[aDecoder decodeObjectForKey:kVSSModelValue] as:[NSString class]];
    NSNumber *confirmed = [[aDecoder decodeObjectForKey:kVSSKeysModelConfirmed] as:[NSNumber class]];
    
    return [self initWithIdb:idb dataClass:(VSSUserDataClass)[classCandidate unsignedIntegerValue] dataType:(VSSUserDataType)[typeCandidate unsignedIntegerValue] value:value confirmed:confirmed];
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    
    if (self.idb != nil) {
        [aCoder encodeObject:self.idb forKey:kVSSKeysModelId];
    }
    if (self.confirmed != nil) {
        [aCoder encodeObject:self.confirmed forKey:kVSSKeysModelConfirmed];
    }
}

#pragma mark - VKSerializable

+ (instancetype)deserializeFrom:(NSDictionary *)candidate {
    NSDictionary *idBundle = [candidate[kVSSKeysModelId] as:[NSDictionary class]];
    VSSIdBundle *idb = [VSSIdBundle deserializeFrom:idBundle];

    NSString *classCandidate = [candidate[kVSSModelClass] as:[NSString class]];
    NSString *typeCandidate = [candidate[kVSSModelType] as:[NSString class]];
    NSString *value = [candidate[kVSSModelValue] as:[NSString class]];
    NSNumber *confirmed = [candidate[kVSSKeysModelConfirmed] as:[NSNumber class]];
    
    return [[self alloc] initWithIdb:idb dataClass:[self userDataClassFromString:classCandidate] dataType:[self userDataTypeFromString:typeCandidate] value:value confirmed:confirmed];
}

#pragma mark - Overrides 

- (NSNumber *)isValid {
    BOOL valid = NO;
    valid = ( [super isValid] && (self.idb.userDataId.length > 0) );
    return [NSNumber numberWithBool:valid];
}

@end
