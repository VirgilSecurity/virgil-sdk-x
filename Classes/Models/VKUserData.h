//
//  VKUserData.h
//  VirgilKeysSDK
//
//  Created by Pavel Gorb on 9/7/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VKBaseModel.h"

extern NSString* const kVKUserDataClassUnknown;
extern NSString* const kVKUserDataClassUserId;
extern NSString* const kVKUserDataClassUserInfo;

typedef NS_ENUM(NSUInteger, VKUserDataClass) {
    UDCUnknown,
    UDCUserId,
    UDCUserInfo
};

extern NSString* const kVKUserDataTypeUnknown;
extern NSString* const kVKUserDataTypeEmail;
extern NSString* const kVKUserDataTypeDomain;
extern NSString* const kVKUserDataTypeApplication;
extern NSString* const kVKUserDataTypeFirstName;
extern NSString* const kVKUserDataTypeLastName;

typedef NS_ENUM(NSUInteger, VKUserDataType) {
    UDTUnknown,
    UDTFirstName,   // Can be used with Class = user_id.
    UDTLastName,    // Can be used with Class = user_id.
    UDTEmail,       // Can be used with Class = user_info.
    UDTDomain,      // Reserved. Not used at the moment.
    UDTApplication  // Reserved. Not used at the moment.
};

@interface VKUserData : VKBaseModel

@property (nonatomic, assign, readonly) VKUserDataClass Class;
@property (nonatomic, assign, readonly) VKUserDataType Type;
@property (nonatomic, copy, readonly) NSString *Value;
@property (nonatomic, copy, readonly) NSNumber *Confirmed;

- (instancetype)initWithId:(VKIdBundle *)Id Class:(VKUserDataClass)Class Type:(VKUserDataType)Type Value:(NSString *)Value Confirmed:(NSNumber *)Confirmed NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithUserData:(VKUserData *)userData;

// Convenient methods for converting enums to strings and vice-versa.
+ (NSString *)stringFromUserDataClass:(VKUserDataClass)Class;
+ (VKUserDataClass)userDataClassFromString:(NSString *)ClassCandidate;

+ (NSString *)stringFromUserDataType:(VKUserDataType)Type;
+ (VKUserDataType)userDataTypeFromString:(NSString *)TypeCandidate;

@end

