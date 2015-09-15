//
//  VKUserData.m
//  VirgilKeysSDK
//
//  Created by Pavel Gorb on 9/7/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import "VKUserData.h"
#import <VirgilFrameworkiOS/NSObject+VFUtils.h>

// String equivalents for enums.
// The following string values will be used in data transfer objects

// String values for UserData class enum.
NSString* const kVKUserDataClassUnknown = @"unknown";
NSString* const kVKUserDataClassUserId = @"user_id";
NSString* const kVKUserDataClassUserInfo = @"user_info";

// String values for UserData type enum.
NSString* const kVKUserDataTypeUnknown = @"unknown";
NSString* const kVKUserDataTypeEmail = @"email";
NSString* const kVKUserDataTypeDomain = @"doimain";
NSString* const kVKUserDataTypeApplication = @"application";
NSString* const kVKUserDataTypeFirstName = @"first_name";
NSString* const kVKUserDataTypeLastName = @"last_name";

@interface VKUserData ()

@property (nonatomic, assign, readwrite) VKUserDataClass Class;
@property (nonatomic, assign, readwrite) VKUserDataType Type;
@property (nonatomic, copy, readwrite) NSString *Value;
@property (nonatomic, copy, readwrite) NSNumber *Confirmed;

@end

@implementation VKUserData

@synthesize Class = _Class;
@synthesize Type = _Type;
@synthesize Value = _Value;
@synthesize Confirmed = _Confirmed;

#pragma mark - Lifecycle

- (instancetype)initWithId:(VKIdBundle *)Id Class:(VKUserDataClass)Class Type:(VKUserDataType)Type Value:(NSString *)Value Confirmed:(NSNumber *)Confirmed {
    self = [super initWithId:Id];
    if (self == nil) {
        return nil;
    }
    
    _Class = Class;
    _Type = Type;
    _Value = [Value copy];
    _Confirmed = [Confirmed copy];
    return self;
}

- (instancetype)initWithId:(VKIdBundle *)Id {
    return [self initWithId:Id Class:UDCUnknown Type:UDTUnknown Value:nil Confirmed:@NO];
}

- (instancetype)initWithUserData:(VKUserData *)userData {
    return [self initWithId:userData.Id Class:userData.Class Type:userData.Type Value:userData.Value Confirmed:userData.Confirmed];
}

- (instancetype)init {
    return [self initWithId:nil Class:UDCUnknown Type:UDTUnknown Value:nil Confirmed:@NO];
}

#pragma mark - NSCopying protocol implementation

- (instancetype)copyWithZone:(NSZone *)zone {
    return [[[self class] alloc] initWithId:self.Id Class:self.Class Type:self.Type Value:self.Value Confirmed:self.Confirmed];
}

#pragma mark - NSCoding protocol implementation

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    VKIdBundle *Id = [[aDecoder decodeObjectForKey:kVKModelId] as:[VKIdBundle class]];
    NSNumber *classCandidate = [[aDecoder decodeObjectForKey:kVKModelClass] as:[NSNumber class]];
    NSNumber *typeCandidate = [[aDecoder decodeObjectForKey:kVKModelType] as:[NSNumber class]];
    NSString *value = [[aDecoder decodeObjectForKey:kVKModelValue] as:[NSString class]];
    NSNumber *confirmed = [[aDecoder decodeObjectForKey:kVKModelConfirmed] as:[NSNumber class]];
    
    return [self initWithId:Id Class:(VKUserDataClass)[classCandidate unsignedIntegerValue] Type:(VKUserDataType)[typeCandidate unsignedIntegerValue] Value:value Confirmed:confirmed];
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    
    [aCoder encodeObject:[NSNumber numberWithUnsignedInteger:self.Class] forKey:kVKModelClass];
    [aCoder encodeObject:[NSNumber numberWithUnsignedInteger:self.Type] forKey:kVKModelType];
    if (self.Value != nil) {
        [aCoder encodeObject:self.Value forKey:kVKModelValue];
    }
    if (self.Confirmed != nil) {
        [aCoder encodeObject:self.Confirmed forKey:kVKModelConfirmed];
    }
}

#pragma mark - VKSerializable

- (NSDictionary *)serialize {
    NSMutableDictionary *dto = [[NSMutableDictionary alloc] initWithDictionary:[super serialize]];
    dto[kVKModelClass] = [[self class] stringFromUserDataClass:self.Class];
    dto[kVKModelType] = [[self class] stringFromUserDataType:self.Type];
    if (self.Value != nil) {
        dto[kVKModelValue] = self.Value;
    }
    
    return dto;
}

+ (instancetype)deserializeFrom:(NSDictionary *)candidate {
    NSDictionary *idBundle = [candidate[kVKModelId] as:[NSDictionary class]];
    VKIdBundle *Id = [VKIdBundle deserializeFrom:idBundle];

    NSString *classCandidate = [candidate[kVKModelClass] as:[NSString class]];
    NSString *typeCandidate = [candidate[kVKModelType] as:[NSString class]];
    NSString *value = [candidate[kVKModelValue] as:[NSString class]];
    NSNumber *confirmed = [candidate[kVKModelConfirmed] as:[NSNumber class]];
    
    return [[self alloc] initWithId:Id Class:[self userDataClassFromString:classCandidate] Type:[self userDataTypeFromString:typeCandidate] Value:value Confirmed:confirmed];
}

#pragma mark - NSObject protocol implementation: equality checks

- (BOOL)isEqual:(id)object {
    VKUserData *ud = [object as:[VKUserData class]];
    if (ud == nil) {
        return NO;
    }
    
    return ([self.Id isEqual:ud.Id]);
}

- (NSUInteger)hash {
    return [self.Id hash];
}

#pragma mark - Overrides 

- (NSNumber *)isValid {
    BOOL valid = NO;
    valid = ( (self.Id.userDataId.length > 0) && (self.Value.length > 0) && (self.Class != UDCUnknown) && (self.Type != UDTUnknown) );
    return [NSNumber numberWithBool:valid];
}

#pragma mark - Public utility logic

+ (NSString *)stringFromUserDataClass:(VKUserDataClass)Class {
    NSString *strClass = nil;
    switch (Class) {
        case UDCUserId:
            strClass = kVKUserDataClassUserId;
            break;
        case UDCUserInfo:
            strClass = kVKUserDataClassUserInfo;
            break;
        default:
            strClass = kVKUserDataClassUnknown;
            break;
    }
    return strClass;
}

+ (VKUserDataClass)userDataClassFromString:(NSString *)ClassCandidate {
    VKUserDataClass cls = UDCUnknown;
    if ([ClassCandidate isEqualToString:kVKUserDataClassUserId]) {
        cls = UDCUserId;
    }
    else if ([ClassCandidate isEqualToString:kVKUserDataClassUserInfo]) {
        cls = UDCUserInfo;
    }
    return cls;
}

+ (NSString *)stringFromUserDataType:(VKUserDataType)Type {
    NSString *strType = nil;
    switch (Type) {
        case UDTFirstName:
            strType = kVKUserDataTypeFirstName;
            break;
        case UDTLastName:
            strType = kVKUserDataTypeLastName;
            break;
        case UDTEmail:
            strType = kVKUserDataTypeEmail;
            break;
        case UDTDomain:
            strType = kVKUserDataTypeDomain;
            break;
        case UDTApplication:
            strType = kVKUserDataTypeApplication;
            break;
        default:
            strType = kVKUserDataTypeUnknown;
            break;
    }
    return strType;
}

+ (VKUserDataType)userDataTypeFromString:(NSString *)TypeCandidate {
    VKUserDataType tp = UDTUnknown;
    if ([TypeCandidate isEqualToString:kVKUserDataTypeFirstName]) {
        tp = UDTFirstName;
    }
    else if ([TypeCandidate isEqualToString:kVKUserDataTypeLastName]) {
        tp = UDTLastName;
    }
    else if ([TypeCandidate isEqualToString:kVKUserDataTypeEmail]) {
        tp = UDTEmail;
    }
    else if ([TypeCandidate isEqualToString:kVKUserDataTypeDomain]) {
        tp = UDTDomain;
    }
    else if ([TypeCandidate isEqualToString:kVKUserDataTypeApplication]) {
        tp = UDTApplication;
    }
    return tp;
}

@end
