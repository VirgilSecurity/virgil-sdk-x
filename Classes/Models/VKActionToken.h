//
//  VKActionToken.h
//  VirgilKeysSDK
//
//  Created by Pavel Gorb on 9/13/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import <VirgilFrameworkiOS/VFModel.h>
#import <VirgilFrameworkiOS/VFTypes.h>

@interface VKActionToken : VFModel

@property (nonatomic, copy, readonly) GUID *tokenId;
@property (nonatomic, copy, readonly) NSArray *userIdList;
@property (nonatomic, copy) NSArray *confirmationCodeList;

@end
