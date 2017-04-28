//
//  MailinatorEmailRequest.m
//  VirgilKeys
//
//  Created by Pavel Gorb on 9/23/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import "MailinatorEmailRequest.h"

#import "MEmail.h"
#import "MEmailResponse.h"
#import "MailinatorRequestSettingsProvider.h"

#import "NSObject+VSSUtils.h"

@interface MailinatorEmailRequest ()

@property (nonatomic, strong, readwrite) MEmail * __nullable email;
@property (nonatomic, strong) NSString * __nonnull emailId;

@end

@implementation MailinatorEmailRequest

#pragma mark - Lifecycle

- (instancetype)initWithContext:(VSSHTTPRequestContext *)context token:(NSString *)token emailId:(NSString *)emailId {
    self = [super initWithContext:context token:token];
    if (self == nil) {
        return nil;
    }
    _emailId = emailId;
    
    [self setRequestMethod:GET];
    return self;
}

#pragma mark - Overrides

- (NSString *)methodPath {
    NSString *token = self.token;
    if (token == nil) {
        return nil;
    }
    return [NSString stringWithFormat:@"email?id=%@&token=%@", self.emailId, token];
}

- (NSError *)handleResponse:(NSObject *)candidate {
    NSError *error = [super handleResponse:candidate];
    if (error != nil) {
        return error;
    }
    
    NSDictionary *emailCandidate = [candidate vss_as:[NSDictionary class]];
    MEmailResponse *response = [MEmailResponse deserializeFrom:emailCandidate];
    self.email = response.email;
    
    return nil;
}

@end
