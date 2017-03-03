//
//  VSSIdentitiesManagerProtocol.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 3/3/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

#import "VSSVirgilIdentity.h"
#import "VSSVirgilGlobalIdentity.h"

@protocol VSSIdentitiesManager <NSObject>

- (VSSVirgilIdentity * __nonnull)createIdentityWithValue:(NSString * __nonnull)value type:(NSString * __nonnull)type;

- (VSSVirgilGlobalIdentity * __nonnull)createGlobalIdentityWithValue:(NSString * __nonnull)value type:(VSSGlobalIdentityType)type;

@end
