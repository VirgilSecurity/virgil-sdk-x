//
//  MailinatorRequestSettingsProvider.h
//  VirgilKeys
//
//  Created by Pavel Gorb on 9/23/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MailinatorRequestSettingsProvider <NSObject>

@required
- (NSString*) mailinatorToken;

@end
