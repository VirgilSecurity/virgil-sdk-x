//
//  VSSDeviceManagerProtocol.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 12/23/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

/**
 Protocol for obtaining Device Info
 */
@protocol VSSDeviceManager <NSObject>

/**
 NSString representing device model
 
 @return NSString with device model
 */
- (NSString * __nonnull)getDeviceModel;

/**
 NSString representing device name
 
 @return NSString with device name
 */
- (NSString * __nonnull)getDeviceName;

@end
