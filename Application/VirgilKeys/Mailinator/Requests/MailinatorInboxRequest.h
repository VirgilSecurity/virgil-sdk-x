//
//  MailinatorInboxRequest.h
//  VirgilKeys
//
//  Created by Pavel Gorb on 9/23/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import "MailinatorRequest.h"

@interface MailinatorInboxRequest : MailinatorRequest

@property (nonatomic, strong, readonly) NSArray *metadataList;

- (instancetype)initWithBaseURL:(NSString *)url provider:(id<MailinatorRequestSettingsProvider>)provider to:(NSString *)to NS_DESIGNATED_INITIALIZER;

@end
