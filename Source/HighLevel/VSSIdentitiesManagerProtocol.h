//
//  VSSIdentitiesManagerProtocol.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 3/3/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

#import "VSSUserIdentity.h"
#import "VSSEmailIdentity.h"
#import "VSSApplicationIdentity.h"

@protocol VSSIdentitiesManager <NSObject>

- (VSSUserIdentity * __nonnull)createUserIdentityWithValue:(NSString * __nonnull)value type:(NSString * __nonnull)type;

- (VSSEmailIdentity * __nonnull)createEmailIdentityWithEmail:(NSString * __nonnull)email;

- (VSSApplicationIdentity * __nonnull)createApplicationIdentityWithName:(NSString * __nonnull)name;

@end
