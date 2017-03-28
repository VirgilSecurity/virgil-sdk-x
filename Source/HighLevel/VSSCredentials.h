//
//  VSSCredentials.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 3/3/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

#import "VSSCredentialsProtocol.h"
#import "VSSCryptoProtocol.h"

/**
 Default implementation of VSSCredentials protocol.
 */
@interface VSSCredentials : NSObject<VSSCredentials>

/**
 Initializes instance with implementation of crypto protocol, private key data, password of this private key, application id.

 @param appKeyData NSData with your application's private key data
 @param password NSString with password of your application's private key
 @param appId NSString with id of your application (Id of Virgil Card of your application)
 @return initialized VSSCredentials instance
 */
- (instancetype __nonnull)initWithAppKeyData:(NSData * __nonnull)appKeyData appKeyPassword:(NSString * __nonnull)password appId:(NSString * __nonnull)appId;

/**
 Unavailable no-argument initializer inherited from NSObject
 */
- (instancetype __nonnull)init NS_UNAVAILABLE;

@end
