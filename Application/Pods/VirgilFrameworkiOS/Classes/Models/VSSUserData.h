//
//  VSSUserData.h
//  VirgilFramework
//
//  Created by Pavel Gorb on 9/7/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VSSModel.h"

extern NSString * __nonnull const kVFModelClass;
extern NSString * __nonnull const kVFModelType;
extern NSString * __nonnull const kVFModelValue;

extern NSString * __nonnull const kVFUserDataClassUnknown;
extern NSString * __nonnull const kVFUserDataClassUserId;
extern NSString * __nonnull const kVFUserDataClassUserInfo;

typedef NS_ENUM(NSUInteger, VFUserDataClass) {
    UDCUnknown,
    UDCUserId,
    UDCUserInfo
};

extern NSString * __nonnull const kVFUserDataTypeUnknown;
extern NSString * __nonnull const kVFUserDataTypeEmail;
extern NSString * __nonnull const kVFUserDataTypeDomain;
extern NSString * __nonnull const kVFUserDataTypeApplication;
extern NSString * __nonnull const kVFUserDataTypeFirstName;
extern NSString * __nonnull const kVFUserDataTypeLastName;

typedef NS_ENUM(NSUInteger, VFUserDataType) {
    UDTUnknown,
    UDTFirstName,   // Can be used with Class = user_id.
    UDTLastName,    // Can be used with Class = user_id.
    UDTEmail,       // Can be used with Class = user_info.
    UDTDomain,      // Reserved. Not used at the moment.
    UDTApplication  // Reserved. Not used at the moment.
};

@interface VSSUserData : VSSModel

@property (nonatomic, assign, readonly) VFUserDataClass dataClass;
@property (nonatomic, assign, readonly) VFUserDataType dataType;
@property (nonatomic, copy, readonly) NSString * __nonnull value;

- (instancetype __nonnull)initWithDataClass:(VFUserDataClass)dataClass dataType:(VFUserDataType)dataType value:(NSString * __nonnull)value NS_DESIGNATED_INITIALIZER;

// Convenient methods for converting enums to strings and vice-versa.
+ (NSString * __nonnull)stringFromUserDataClass:(VFUserDataClass)dataClass;
+ (VFUserDataClass)userDataClassFromString:(NSString * __nullable)classCandidate;

+ (NSString * __nonnull)stringFromUserDataType:(VFUserDataType)dataType;
+ (VFUserDataType)userDataTypeFromString:(NSString * __nullable)typeCandidate;

@end

