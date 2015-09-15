//
//  VKDeleteUserDataRequest.h
//  VirgilKeysSDK
//
//  Created by Pavel Gorb on 9/14/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import "VKBaseRequest.h"
#import "VKIdBundle.h"

@interface VKDeleteUserDataRequest : VKBaseRequest

- (instancetype)initWithBaseURL:(NSString *)url userDataId:(GUID *)userDataId NS_DESIGNATED_INITIALIZER;

@end
