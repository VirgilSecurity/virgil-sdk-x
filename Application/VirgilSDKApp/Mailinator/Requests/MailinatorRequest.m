//
//  MailinatorRequest.m
//  VirgilKeys
//
//  Created by Pavel Gorb on 9/23/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import "MailinatorRequest.h"
#import "MailinatorRequestSettingsProvider.h"

#import "VSSError.h"
#import "NSObject+VSSUtils.h"

@interface MailinatorRequest ()

@property (nonatomic, weak, readwrite) id<MailinatorRequestSettingsProvider> __nullable provider;

@end

@implementation MailinatorRequest

@synthesize provider = _provider;

- (instancetype)initWithContext:(VSSRequestContext *)context provider:(id<MailinatorRequestSettingsProvider>)provider {
    self = [super initWithContext:context];
    if (self == nil) {
        return nil;
    }
    
    _provider = provider;
    return self;
}

- (NSError *)handleError:(NSObject *)candidate {
    NSError *error = [super handleError:candidate];
    if (error != nil) {
        return error;
    }
    
    VSSError *vfError = [VSSError deserializeFrom:[candidate as:[NSDictionary class]]];
    return vfError.nsError;
}

@end
