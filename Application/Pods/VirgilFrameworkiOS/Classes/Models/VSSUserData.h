//
//  VSSUserData.h
//  VirgilFramework
//
//  Created by Pavel Gorb on 9/7/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VSSModel.h"

extern NSString * __nonnull const kVSSModelClass;
extern NSString * __nonnull const kVSSModelType;
extern NSString * __nonnull const kVSSModelValue;

extern NSString * __nonnull const kVSSUserDataClassUnknown;
extern NSString * __nonnull const kVSSUserDataClassUserId;
extern NSString * __nonnull const kVSSUserDataClassUserInfo;

typedef NS_ENUM(NSUInteger, VSSUserDataClass) {
    UDCUnknown,
    UDCUserId,
    UDCUserInfo
};

extern NSString * __nonnull const kVSSUserDataTypeUnknown;
extern NSString * __nonnull const kVSSUserDataTypeEmail;
extern NSString * __nonnull const kVSSUserDataTypeDomain;
extern NSString * __nonnull const kVSSUserDataTypeApplication;
extern NSString * __nonnull const kVSSUserDataTypeFirstName;
extern NSString * __nonnull const kVSSUserDataTypeLastName;

typedef NS_ENUM(NSUInteger, VSSUserDataType) {
    UDTUnknown,
    UDTFirstName,   // Can be used with Class = user_id.
    UDTLastName,    // Can be used with Class = user_id.
    UDTEmail,       // Can be used with Class = user_info.
    UDTDomain,      // Reserved. Not used at the moment.
    UDTApplication  // Reserved. Not used at the moment.
};

@interface VSSUserData : VSSModel

@property (nonatomic, assign, readonly) VSSUserDataClass dataClass;
@property (nonatomic, assign, readonly) VSSUserDataType dataType;
@property (nonatomic, copy, readonly) NSString * __nonnull value;

- (instancetype __nonnull)initWithDataClass:(VSSUserDataClass)dataClass dataType:(VSSUserDataType)dataType value:(NSString * __nonnull)value NS_DESIGNATED_INITIALIZER;

// Convenient methods for converting enums to strings and vice-versa.
+ (NSString * __nonnull)stringFromUserDataClass:(VSSUserDataClass)dataClass;
+ (VSSUserDataClass)userDataClassFromString:(NSString * __nullable)classCandidate;

+ (NSString * __nonnull)stringFromUserDataType:(VSSUserDataType)dataType;
+ (VSSUserDataType)userDataTypeFromString:(NSString * __nullable)typeCandidate;

@end

