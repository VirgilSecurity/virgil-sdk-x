//
//  VSSUserData.m
//  VirgilKit
//
//  Created by Pavel Gorb on 9/7/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import "VSSUserData.h"
#import "VSSUserData_Protected.h"
#import "NSObject+VSSUtils.h"

NSString *const kVSSModelClass = @"class";
NSString *const kVSSModelType = @"type";
NSString *const kVSSModelValue = @"value";

// String equivalents for enums.
// The following string values will be used in data transfer objects

// String values for UserData class enum.
NSString* const kVSSUserDataClassUnknown = @"unknown";
NSString* const kVSSUserDataClassUserId = @"user_id";
NSString* const kVSSUserDataClassUserInfo = @"user_info";

// String values for UserData type enum.
NSString* const kVSSUserDataTypeUnknown = @"unknown";
NSString* const kVSSUserDataTypeEmail = @"email";
NSString* const kVSSUserDataTypeDomain = @"doimain";
NSString* const kVSSUserDataTypeApplication = @"application";
NSString* const kVSSUserDataTypeFirstName = @"first_name";
NSString* const kVSSUserDataTypeLastName = @"last_name";

@implementation VSSUserData

@synthesize dataClass = _dataClass;
@synthesize dataType = _dataType;
@synthesize value = _value;

#pragma mark - Lifecycle

- (instancetype)initWithDataClass:(VSSUserDataClass)dataClass dataType:(VSSUserDataType)dataType value:(NSString *)value {
    self = [super init];
    if (self == nil) {
        return nil;
    }
    
    _dataClass = dataClass;
    _dataType = dataType;
    _value = [value copy];
    return self;
}

- (instancetype)init {
    return [self initWithDataClass:UDCUnknown dataType:UDTUnknown value:@""];
}

#pragma mark - NSCopying protocol implementation

- (instancetype)copyWithZone:(NSZone *)zone {
    return [[[self class] alloc] initWithDataClass:self.dataClass dataType:self.dataType value:self.value];
}

#pragma mark - NSCoding protocol implementation

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    NSNumber *classCandidate = [[aDecoder decodeObjectForKey:kVSSModelClass] as:[NSNumber class]];
    NSNumber *typeCandidate = [[aDecoder decodeObjectForKey:kVSSModelType] as:[NSNumber class]];
    NSString *value = [[aDecoder decodeObjectForKey:kVSSModelValue] as:[NSString class]];
    
    return [self initWithDataClass:(VSSUserDataClass)[classCandidate unsignedIntegerValue] dataType:(VSSUserDataType)[typeCandidate unsignedIntegerValue] value:value];
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    
    [aCoder encodeObject:[NSNumber numberWithUnsignedInteger:self.dataClass] forKey:kVSSModelClass];
    [aCoder encodeObject:[NSNumber numberWithUnsignedInteger:self.dataType] forKey:kVSSModelType];
    if (self.value != nil) {
        [aCoder encodeObject:self.value forKey:kVSSModelValue];
    }
}

#pragma mark - VFSerializable

- (NSDictionary *)serialize {
    NSMutableDictionary *dto = [[NSMutableDictionary alloc] initWithDictionary:[super serialize]];
    dto[kVSSModelClass] = [[self class] stringFromUserDataClass:self.dataClass];
    dto[kVSSModelType] = [[self class] stringFromUserDataType:self.dataType];
    if (self.value != nil) {
        dto[kVSSModelValue] = self.value;
    }
    
    return dto;
}

+ (instancetype)deserializeFrom:(NSDictionary *)candidate {
    NSString *classCandidate = [candidate[kVSSModelClass] as:[NSString class]];
    NSString *typeCandidate = [candidate[kVSSModelType] as:[NSString class]];
    NSString *value = [candidate[kVSSModelValue] as:[NSString class]];
    
    return [[self alloc] initWithDataClass:[self userDataClassFromString:classCandidate] dataType:[self userDataTypeFromString:typeCandidate] value:value];
}

#pragma mark - NSObject protocol implementation: equality checks

- (BOOL)isEqual:(id)object {
    VSSUserData *ud = [object as:[VSSUserData class]];
    if (ud == nil) {
        return NO;
    }
    
    return ( (self.dataClass == ud.dataClass) && (self.dataType == ud.dataType) && [self.value isEqualToString:ud.value] );
}

- (NSUInteger)hash {
    return [[NSString stringWithFormat:@"%@%@%@", [[self class] stringFromUserDataClass:self.dataClass], [[self class] stringFromUserDataType:self.dataType], self.value] hash];
}

#pragma mark - Overrides 

- (NSNumber *)isValid {
    BOOL valid = NO;
    valid = ( (self.value.length > 0) && (self.dataClass != UDCUnknown) && (self.dataType != UDTUnknown) );
    return [NSNumber numberWithBool:valid];
}

#pragma mark - Public utility logic

+ (NSString *)stringFromUserDataClass:(VSSUserDataClass)dataClass {
    NSString *strClass = nil;
    switch (dataClass) {
        case UDCUserId:
            strClass = kVSSUserDataClassUserId;
            break;
        case UDCUserInfo:
            strClass = kVSSUserDataClassUserInfo;
            break;
        default:
            strClass = kVSSUserDataClassUnknown;
            break;
    }
    return strClass;
}

+ (VSSUserDataClass)userDataClassFromString:(NSString *)classCandidate {
    VSSUserDataClass cls = UDCUnknown;
    if ([classCandidate isEqualToString:kVSSUserDataClassUserId]) {
        cls = UDCUserId;
    }
    else if ([classCandidate isEqualToString:kVSSUserDataClassUserInfo]) {
        cls = UDCUserInfo;
    }
    return cls;
}

+ (NSString *)stringFromUserDataType:(VSSUserDataType)dataType {
    NSString *strType = nil;
    switch (dataType) {
        case UDTFirstName:
            strType = kVSSUserDataTypeFirstName;
            break;
        case UDTLastName:
            strType = kVSSUserDataTypeLastName;
            break;
        case UDTEmail:
            strType = kVSSUserDataTypeEmail;
            break;
        case UDTDomain:
            strType = kVSSUserDataTypeDomain;
            break;
        case UDTApplication:
            strType = kVSSUserDataTypeApplication;
            break;
        default:
            strType = kVSSUserDataTypeUnknown;
            break;
    }
    return strType;
}

+ (VSSUserDataType)userDataTypeFromString:(NSString *)typeCandidate {
    VSSUserDataType tp = UDTUnknown;
    if ([typeCandidate isEqualToString:kVSSUserDataTypeFirstName]) {
        tp = UDTFirstName;
    }
    else if ([typeCandidate isEqualToString:kVSSUserDataTypeLastName]) {
        tp = UDTLastName;
    }
    else if ([typeCandidate isEqualToString:kVSSUserDataTypeEmail]) {
        tp = UDTEmail;
    }
    else if ([typeCandidate isEqualToString:kVSSUserDataTypeDomain]) {
        tp = UDTDomain;
    }
    else if ([typeCandidate isEqualToString:kVSSUserDataTypeApplication]) {
        tp = UDTApplication;
    }
    return tp;
}

@end
