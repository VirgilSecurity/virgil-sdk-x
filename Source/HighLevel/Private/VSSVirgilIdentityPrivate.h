//
//  VSSVirgilIdentityPrivate.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 3/3/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

#import "VSSVirgilIdentity.h"
#import "VSSVirgilApiContext.h"

@interface VSSVirgilIdentity ()

@property (nonatomic, readonly) VSSVirgilApiContext * __nonnull context;

- (instancetype __nonnull)initWithContext:(VSSVirgilApiContext * __nonnull)context value:(NSString * __nonnull)value type:(NSString * __nonnull)type NS_DESIGNATED_INITIALIZER;
    
- (VSSCreateCardRequest * __nullable)generateRequestWithPublicKeyData:(NSData * __nonnull)publicKeyData data:(NSDictionary<NSString *, NSString *> * __nullable)data device:(NSString * __nullable)device deviceName:(NSString * __nullable)deviceName;

@end
