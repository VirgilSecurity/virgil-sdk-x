//
//  VFUserData.m
//  VirgilFramework
//
//  Created by Pavel Gorb on 9/7/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import "VFUserData.h"
#import "VFUserData_Protected.h"
#import "NSObject+VFUtils.h"

NSString *const kVFModelClass = @"class";
NSString *const kVFModelType = @"type";
NSString *const kVFModelValue = @"value";

// String equivalents for enums.
// The following string values will be used in data transfer objects

// String values for UserData class enum.
NSString* const kVFUserDataClassUnknown = @"unknown";
NSString* const kVFUserDataClassUserId = @"user_id";
NSString* const kVFUserDataClassUserInfo = @"user_info";

// String values for UserData type enum.
NSString* const kVFUserDataTypeUnknown = @"unknown";
NSString* const kVFUserDataTypeEmail = @"email";
NSString* const kVFUserDataTypeDomain = @"doimain";
NSString* const kVFUserDataTypeApplication = @"application";
NSString* const kVFUserDataTypeFirstName = @"first_name";
NSString* const kVFUserDataTypeLastName = @"last_name";

@implementation VFUserData

@synthesize dataClass = _dataClass;
@synthesize dataType = _dataType;
@synthesize value = _value;

#pragma mark - Lifecycle

- (instancetype)initWithDataClass:(VFUserDataClass)dataClass dataType:(VFUserDataType)dataType value:(NSString *)value {
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
    NSNumber *classCandidate = [[aDecoder decodeObjectForKey:kVFModelClass] as:[NSNumber class]];
    NSNumber *typeCandidate = [[aDecoder decodeObjectForKey:kVFModelType] as:[NSNumber class]];
    NSString *value = [[aDecoder decodeObjectForKey:kVFModelValue] as:[NSString class]];
    
    return [self initWithDataClass:(VFUserDataClass)[classCandidate unsignedIntegerValue] dataType:(VFUserDataType)[typeCandidate unsignedIntegerValue] value:value];
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    
    [aCoder encodeObject:[NSNumber numberWithUnsignedInteger:self.dataClass] forKey:kVFModelClass];
    [aCoder encodeObject:[NSNumber numberWithUnsignedInteger:self.dataType] forKey:kVFModelType];
    if (self.value != nil) {
        [aCoder encodeObject:self.value forKey:kVFModelValue];
    }
}

#pragma mark - VFSerializable

- (NSDictionary *)serialize {
    NSMutableDictionary *dto = [[NSMutableDictionary alloc] initWithDictionary:[super serialize]];
    dto[kVFModelClass] = [[self class] stringFromUserDataClass:self.dataClass];
    dto[kVFModelType] = [[self class] stringFromUserDataType:self.dataType];
    if (self.value != nil) {
        dto[kVFModelValue] = self.value;
    }
    
    return dto;
}

+ (instancetype)deserializeFrom:(NSDictionary *)candidate {
    NSString *classCandidate = [candidate[kVFModelClass] as:[NSString class]];
    NSString *typeCandidate = [candidate[kVFModelType] as:[NSString class]];
    NSString *value = [candidate[kVFModelValue] as:[NSString class]];
    
    return [[self alloc] initWithDataClass:[self userDataClassFromString:classCandidate] dataType:[self userDataTypeFromString:typeCandidate] value:value];
}

#pragma mark - NSObject protocol implementation: equality checks

- (BOOL)isEqual:(id)object {
    VFUserData *ud = [object as:[VFUserData class]];
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

+ (NSString *)stringFromUserDataClass:(VFUserDataClass)dataClass {
    NSString *strClass = nil;
    switch (dataClass) {
        case UDCUserId:
            strClass = kVFUserDataClassUserId;
            break;
        case UDCUserInfo:
            strClass = kVFUserDataClassUserInfo;
            break;
        default:
            strClass = kVFUserDataClassUnknown;
            break;
    }
    return strClass;
}

+ (VFUserDataClass)userDataClassFromString:(NSString *)classCandidate {
    VFUserDataClass cls = UDCUnknown;
    if ([classCandidate isEqualToString:kVFUserDataClassUserId]) {
        cls = UDCUserId;
    }
    else if ([classCandidate isEqualToString:kVFUserDataClassUserInfo]) {
        cls = UDCUserInfo;
    }
    return cls;
}

+ (NSString *)stringFromUserDataType:(VFUserDataType)dataType {
    NSString *strType = nil;
    switch (dataType) {
        case UDTFirstName:
            strType = kVFUserDataTypeFirstName;
            break;
        case UDTLastName:
            strType = kVFUserDataTypeLastName;
            break;
        case UDTEmail:
            strType = kVFUserDataTypeEmail;
            break;
        case UDTDomain:
            strType = kVFUserDataTypeDomain;
            break;
        case UDTApplication:
            strType = kVFUserDataTypeApplication;
            break;
        default:
            strType = kVFUserDataTypeUnknown;
            break;
    }
    return strType;
}

+ (VFUserDataType)userDataTypeFromString:(NSString *)typeCandidate {
    VFUserDataType tp = UDTUnknown;
    if ([typeCandidate isEqualToString:kVFUserDataTypeFirstName]) {
        tp = UDTFirstName;
    }
    else if ([typeCandidate isEqualToString:kVFUserDataTypeLastName]) {
        tp = UDTLastName;
    }
    else if ([typeCandidate isEqualToString:kVFUserDataTypeEmail]) {
        tp = UDTEmail;
    }
    else if ([typeCandidate isEqualToString:kVFUserDataTypeDomain]) {
        tp = UDTDomain;
    }
    else if ([typeCandidate isEqualToString:kVFUserDataTypeApplication]) {
        tp = UDTApplication;
    }
    return tp;
}

@end
