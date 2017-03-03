//
//  VSSCredentials.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 3/3/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

#import "VSSCredentialsProtocol.h"
#import "VSSCryptoProtocol.h"

@interface VSSCredentials : NSObject<VSSCredentials>

/**
 Unavailable no-argument initializer inherited from NSObject
 */
- (instancetype __nonnull)init NS_UNAVAILABLE;

- (instancetype __nullable)initWithCrypto:(id<VSSCrypto> __nonnull)crypto appKeyData:(NSData * __nonnull)appKeyData appKeyPassword:(NSString * __nonnull)password appId:(NSString * __nonnull)appId;

@end
