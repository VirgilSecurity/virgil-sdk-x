//
//  Mailinator.m
//  VirgilKeys
//
//  Created by Pavel Gorb on 9/23/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import "Mailinator.h"
#import "MEmail.h"

#import "MailinatorInboxRequest.h"
#import "MailinatorEmailRequest.h"
#import "MailinatorConfig.h"

#import "NSObject+VSSUtils.h"
#import "VSSRequestContextExtended.h"

static NSString *const kMailinatorErrorDomain = @"MailinatorErrorDomain";

@implementation Mailinator

#pragma mark - Overrides

- (void)getInbox:(NSString *)name completionHandler:(void(^)(NSArray *metadataList, NSError *error))completionHandler {
    if (name == nil) {
        if (completionHandler != nil) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                completionHandler(nil, [NSError errorWithDomain:kMailinatorErrorDomain code:-100 userInfo:@{ NSLocalizedDescriptionKey: NSLocalizedString(@"Request for the inbox data can not be sent. Inbox name is not set.", @"GetInbox") }]);
            });
        }
        return;
    }
    
    VSSRequestCompletionHandler handler = ^(VSSRequest *request) {
        if (request.error != nil) {
            if (completionHandler != nil) {
                completionHandler(nil, request.error);
            }
            return;
        }
        
        if (completionHandler != nil) {
            MailinatorInboxRequest *mrequest = [request as:[MailinatorInboxRequest class]];
            completionHandler(mrequest.metadataList, nil);
        }
    };
    
    VSSRequestContextExtended *context = [[VSSRequestContextExtended alloc] initWithServiceUrl:[self.serviceConfig serviceURLForServiceID:kMailinatorID]];
    MailinatorInboxRequest *request = [[MailinatorInboxRequest alloc] initWithContext:context provider:self to:name];
    request.completionHandler = handler;
    [self send:request];
}

- (void)getEmail:(NSString *)emailId completionHandler:(void(^)(MEmail *email, NSError *error))completionHandler {
    if (emailId == nil) {
        if (completionHandler != nil) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                completionHandler(nil, [NSError errorWithDomain:kMailinatorErrorDomain code:-102 userInfo:@{ NSLocalizedDescriptionKey: NSLocalizedString(@"Request for the email data can not be sent. Email id is not set.", @"GetEmail") }]);
            });
        }
        return;
    }
    
    VSSRequestCompletionHandler handler = ^(VSSRequest *request) {
        if (request.error != nil) {
            if (completionHandler != nil) {
                completionHandler(nil, request.error);
            }
            return;
        }
        
        if (completionHandler != nil) {
            MailinatorEmailRequest *mrequest = [request as:[MailinatorEmailRequest class]];
            completionHandler(mrequest.email, nil);
        }
    };
    
    VSSRequestContextExtended *context = [[VSSRequestContextExtended alloc] initWithServiceUrl:[self.serviceConfig serviceURLForServiceID:kMailinatorID]];
    MailinatorEmailRequest *request = [[MailinatorEmailRequest alloc] initWithContext:context provider:self emailId:emailId];
    request.completionHandler = handler;
    [self send:request];
}

#pragma mark - MailinatorRequestSettingsProvider

- (NSString *)mailinatorToken {
    return self.token;
}

@end
