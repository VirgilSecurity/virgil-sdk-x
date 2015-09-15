//
//  VKPersistUserDataRequest.h
//  VirgilKeysSDK
//
//  Created by Pavel Gorb on 9/14/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import "VKBaseRequest.h"
#import "VKIdBundle.h"

@interface VKPersistUserDataRequest : VKBaseRequest

- (instancetype)initWithBaseURL:(NSString *)url userDataId:(GUID *)userDataId confirmationCode:(NSString *)code NS_DESIGNATED_INITIALIZER;

@end
