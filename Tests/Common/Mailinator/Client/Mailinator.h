//
//  Mailinator.h
//  VirgilKeys
//
//  Created by Pavel Gorb on 9/23/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import "MailinatorRequestSettingsProvider.h"

@class MEmail;
@class MEmailMetadata;

@interface Mailinator : NSObject

@property (nonatomic, copy, readonly) NSURL * __nonnull serviceUrl;
@property (nonatomic, copy, readonly) NSString * __nonnull token;

- (instancetype __nonnull)initWithApplicationToken:(NSString * __nonnull)token serviceUrl:(NSURL * __nonnull)serviceUrl;

- (void)getInbox:(NSString * __nonnull)name completionHandler:(void(^ __nullable)(NSArray<MEmailMetadata *> * __nullable metadataList, NSError * __nullable error))completionHandler;
- (void)getEmail:(NSString * __nonnull)emailId completionHandler:(void(^ __nullable)(MEmail * __nullable email, NSError * __nullable error))completionHandler;

@end
