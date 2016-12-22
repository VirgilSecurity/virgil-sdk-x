//
//  VSSVirgilBaseKey.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 11/10/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSVirgilCard.h"

@interface VSSVirgilBaseKey : NSObject

- (BOOL)signRequest:(id<VSSSignable> __nonnull)request error:(NSError * __nullable * __nullable)errorPtr;

- (NSData * __nullable)generateSignatureForData:(NSData * __nonnull)data error:(NSError * __nullable * __nullable)errorPtr;

- (NSData * __nullable)decryptData:(NSData * __nonnull)data error:(NSError * __nullable * __nullable)errorPtr;

- (NSData * __nullable)signThenEncryptData:(NSData * __nonnull)data forRecipients:(NSArray<VSSVirgilCard *> * __nonnull)recipients error:(NSError * __nullable * __nullable)errorPtr;

- (NSData * __nullable)decryptThenVerifyData:(NSData * __nonnull)data fromSigner:(VSSVirgilCard * __nonnull)signer error:(NSError * __nullable * __nullable)errorPtr;

/**
 Unavailable no-argument initializer inherited from NSObject
 */
- (instancetype __nonnull)init NS_UNAVAILABLE;

@end
