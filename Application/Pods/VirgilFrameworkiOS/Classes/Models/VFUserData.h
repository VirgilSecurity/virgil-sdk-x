//
//  VFUserData.h
//  VirgilFramework
//
//  Created by Pavel Gorb on 9/7/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VFModel.h"

extern NSString *const kVFModelClass;
extern NSString *const kVFModelType;
extern NSString *const kVFModelValue;

extern NSString* const kVFUserDataClassUnknown;
extern NSString* const kVFUserDataClassUserId;
extern NSString* const kVFUserDataClassUserInfo;

typedef NS_ENUM(NSUInteger, VFUserDataClass) {
    UDCUnknown,
    UDCUserId,
    UDCUserInfo
};

extern NSString* const kVFUserDataTypeUnknown;
extern NSString* const kVFUserDataTypeEmail;
extern NSString* const kVFUserDataTypeDomain;
extern NSString* const kVFUserDataTypeApplication;
extern NSString* const kVFUserDataTypeFirstName;
extern NSString* const kVFUserDataTypeLastName;

typedef NS_ENUM(NSUInteger, VFUserDataType) {
    UDTUnknown,
    UDTFirstName,   // Can be used with Class = user_id.
    UDTLastName,    // Can be used with Class = user_id.
    UDTEmail,       // Can be used with Class = user_info.
    UDTDomain,      // Reserved. Not used at the moment.
    UDTApplication  // Reserved. Not used at the moment.
};

@interface VFUserData : VFModel

@property (nonatomic, assign, readonly) VFUserDataClass dataClass;
@property (nonatomic, assign, readonly) VFUserDataType dataType;
@property (nonatomic, copy, readonly) NSString *value;

- (instancetype)initWithDataClass:(VFUserDataClass)dataClass dataType:(VFUserDataType)dataType value:(NSString *)value NS_DESIGNATED_INITIALIZER;

// Convenient methods for converting enums to strings and vice-versa.
+ (NSString *)stringFromUserDataClass:(VFUserDataClass)dataClass;
+ (VFUserDataClass)userDataClassFromString:(NSString *)classCandidate;

+ (NSString *)stringFromUserDataType:(VFUserDataType)dataType;
+ (VFUserDataType)userDataTypeFromString:(NSString *)typeCandidate;

@end

