//
//  Mailinator.h
//  VirgilKeys
//
//  Created by Pavel Gorb on 9/23/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import "MailinatorRequestSettingsProvider.h"
#import "VSSBaseClient.h"

@class MEmail;

@interface Mailinator : VSSBaseClient <MailinatorRequestSettingsProvider>

- (void)getInbox:(NSString * __nonnull)name completionHandler:(void(^ __nullable)(NSArray * __nullable metadataList, NSError * __nullable error))completionHandler;
- (void)getEmail:(NSString * __nonnull)emailId completionHandler:(void(^ __nullable)(MEmail * __nullable email, NSError * __nullable error))completionHandler;

@end
