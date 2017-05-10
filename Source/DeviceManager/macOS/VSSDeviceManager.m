//
//  VSSDeviceManager_Foundation.m
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 4/28/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VSSDeviceManager.h"
#import <sys/sysctl.h>

@implementation VSSDeviceManager

- (NSString *)getDeviceModel {
    size_t size;
    char *typeSpecifier = "hw.model";
    sysctlbyname(typeSpecifier, NULL, &size, NULL, 0);
    
    char *answer = malloc(size);
    sysctlbyname(typeSpecifier, answer, &size, NULL, 0);
    
    NSString *results = [NSString stringWithCString:answer encoding: NSUTF8StringEncoding];
    
    free(answer);
    return results;
}

- (NSString *)getDeviceName {
    char *answer = getenv("USER");
    
    NSString *results = [NSString stringWithCString:answer encoding: NSUTF8StringEncoding];

    return results;
}

@end
