//
//  VSSDeviceManager_UIKIT.m
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 12/23/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "VSSDeviceManager.h"

@implementation VSSDeviceManager

- (NSString *)getDeviceModel {
    return [UIDevice currentDevice].model;
}

- (NSString *)getDeviceName {
    return [UIDevice currentDevice].name;
}

@end
