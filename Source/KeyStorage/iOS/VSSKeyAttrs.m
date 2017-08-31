//
//  VSSKeyAttrs.m
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 8/23/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

#import "VSSKeyAttrs.h"
#import "VSSKeyAttrsPrivate.h"

@implementation VSSKeyAttrs

- (instancetype)initWithName:(NSString *)name creationDate:(NSDate *)creationDate {
    self = [super init];
    
    if (self) {
        _name = [name copy];
        _creationDate = [creationDate copy];
    }
    
    return self;
}

@end
