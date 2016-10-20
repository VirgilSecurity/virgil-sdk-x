//
//  VSSDeviceInfoUtils.m
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 10/4/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "VSSDeviceInfoUtils.h"

@implementation VSSDeviceInfoUtils

+ (NSString *)getDeviceModel {
    return [UIDevice currentDevice].model;
}

+ (NSString *)getDeviceName {
    return [UIDevice currentDevice].name;
}

@end
