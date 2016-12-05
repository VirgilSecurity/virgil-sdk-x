//
//  VSSRequestSignerProtocol.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 11/8/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "VSSSignable.h"
#import "VSSPrivateKey.h"

@protocol VSSRequestSigner <NSObject>

/**
 Adds owner's signature to given VSSSignableRequest using provided VSSPrivateKey
 
 @param request VSSSignableRequest instance to be signed
 @param privateKey VSSPrivateKey which represents owner's private key and is used for calculating signature
 @param errorPtr NSError pointer to return error if needed
 @return BOOL value which indicates whether signing succeeded or failed
 */
- (BOOL)selfSignRequest:(id<VSSSignable> __nonnull)request withPrivateKey:(VSSPrivateKey * __nonnull)privateKey error:(NSError * __nullable * __nullable)errorPtr NS_SWIFT_NAME(selfSign(_:with:));

/**
 Adds Authority signature
 
 @param request VSSSignableRequest instance to be signed
 @param appId NSString which represents Authority identifier (for example, AppID)
 @param privateKey VSSPrivateKey which represents authority's private key and is used for calculating signature
 @param errorPtr NSError pointer to return error if needed
 @return BOOL value which indicates whether signing succeeded or failed
 */
- (BOOL)authoritySignRequest:(id<VSSSignable> __nonnull)request forAppId:(NSString * __nonnull)appId withPrivateKey:(VSSPrivateKey * __nonnull)privateKey error:(NSError * __nullable * __nullable)errorPtr NS_SWIFT_NAME(authoritySign(_:forAppId:with:));

@end
