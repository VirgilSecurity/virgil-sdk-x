//
//  MailinatorEmailRequest.h
//  VirgilKeys
//
//  Created by Pavel Gorb on 9/23/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import "MailinatorRequest.h"

@class MEmail;

@interface MailinatorEmailRequest : MailinatorRequest

@property (nonatomic, strong, readonly) MEmail *email;

- (instancetype)initWithBaseURL:(NSString *)url provider:(id<MailinatorRequestSettingsProvider>)provider emailId:(NSString *)emailId NS_DESIGNATED_INITIALIZER;

@end
