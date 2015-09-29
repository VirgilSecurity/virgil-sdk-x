//
//  MailinatorRequest.h
//  VirgilKeys
//
//  Created by Pavel Gorb on 9/23/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import "VFJSONRequest.h"

@protocol MailinatorRequestSettingsProvider;

@interface MailinatorRequest : VFJSONRequest

@property (nonatomic, weak, readonly) id<MailinatorRequestSettingsProvider> provider;

- (instancetype)initWithBaseURL:(NSString *)url provider:(id<MailinatorRequestSettingsProvider>)provider NS_DESIGNATED_INITIALIZER;

@end
