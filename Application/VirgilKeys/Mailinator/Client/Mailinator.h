//
//  Mailinator.h
//  VirgilKeys
//
//  Created by Pavel Gorb on 9/23/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import "MailinatorRequestSettingsProvider.h"
#import <VirgilFrameworkiOS/VSSClient.h>

@class MEmail;

@interface Mailinator : VSSClient <MailinatorRequestSettingsProvider>

- (void)getInbox:(NSString *)name completionHandler:(void(^)(NSArray *metadataList, NSError *error))completionHandler;
- (void)getEmail:(NSString *)emailId completionHandler:(void(^)(MEmail *email, NSError *error))completionHandler;

@end
