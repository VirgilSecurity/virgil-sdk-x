//
//  VSSAuthAckResponse.m
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 3/23/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

#import "VSSAuthAckResponse.h"
#import "VSSModelKeys.h"
#import "NSObject+VSSUtils.h"

@implementation VSSAuthAckResponse

#pragma mark - VSSDeserializable

- (instancetype)initWithDict:(NSDictionary *)candidate {
    NSString *code = [candidate[kVSSAModelCode] vss_as:[NSString class]];
    if (code.length == 0)
        return nil;
    
    self = [super init];
    
    if (self) {
        _code = [code copy];
    }
    
    return self;
}

@end
