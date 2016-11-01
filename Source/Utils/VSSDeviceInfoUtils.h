//
//  VSSDeviceInfoUtils.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 10/4/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

/**
 Class for convenient architecture-specific methods for obtaining Device Info
 */
@interface VSSDeviceInfoUtils : NSObject

/**
 NSString representing device model

 @return NSString with device model
 */
+ (NSString * __nonnull)getDeviceModel;

/**
 NSString representing device name

 @return NSString with device name
 */
+ (NSString * __nonnull)getDeviceName;

@end
