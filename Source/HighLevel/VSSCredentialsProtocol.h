//
//  VSSCredentialsProtocol.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 3/3/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

#import "VSSPrivateKey.h"
#import "VSSCryptoProtocol.h"

/**
 Protocol used for providing credentials for your application in Virgil Service.
 See default implementation in VSSCredentials class.
 */
@protocol VSSCredentials <NSObject>

/**
 Private Key of your application generated while creating application in Dashboard.

 @param crypto VSSCrypto protocol implementation used to import private key
 @return VSSPrivateKey instance with your application's private key
 */
- (VSSPrivateKey * __nullable)getAppKeyUsingCrypto:(id<VSSCrypto> __nonnull)crypto;

/**
 NSString with Id of your application (id of Virgil Card of your application)
 */
@property (nonatomic, readonly) NSString * __nullable appId;

@end
