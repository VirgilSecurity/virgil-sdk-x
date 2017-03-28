//
//  VSSVirgilKey.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 2/14/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VSSVirgilCard.h"

@interface VSSVirgilKey : NSObject

- (NSData * __nonnull)exportWithPassword:(NSString * __nullable)password;

- (NSData * __nullable)generateSignatureForData:(NSData * __nonnull)data error:(NSError * __nullable * __nullable)errorPtr;

- (NSData * __nullable)generateSignatureForString:(NSString * __nonnull)string error:(NSError * __nullable * __nullable)errorPtr;

- (NSData * __nullable)decryptData:(NSData * __nonnull)data error:(NSError * __nullable * __nullable)errorPtr NS_SWIFT_NAME(decrypt(_:));

- (NSData * __nullable)decryptBase64String:(NSString * __nonnull)base64String error:(NSError * __nullable * __nullable)errorPtr NS_SWIFT_NAME(decrypt(_:));

- (NSData * __nullable)signThenEncryptData:(NSData * __nonnull)data forRecipients:(NSArray<VSSVirgilCard *> * __nonnull)recipients error:(NSError * __nullable * __nullable)errorPtr NS_SWIFT_NAME(signThenEncrypt(_:for:));

- (NSData * __nullable)signThenEncryptString:(NSString * __nonnull)string forRecipients:(NSArray<VSSVirgilCard *> * __nonnull)recipients error:(NSError * __nullable * __nullable)errorPtr NS_SWIFT_NAME(signThenEncrypt(_:for:));

- (NSData * __nullable)decryptThenVerifyData:(NSData * __nonnull)data from:(VSSVirgilCard * __nonnull)card error:(NSError * __nullable * __nullable)errorPtr NS_SWIFT_NAME(decryptThenVerify(_:from:));

- (NSData * __nullable)decryptThenVerifyData:(NSData * __nonnull)data fromOneOf:(NSArray<VSSVirgilCard *> * __nonnull)cards error:(NSError * __nullable * __nullable)errorPtr NS_SWIFT_NAME(decryptThenVerify(_:fromOneOf:));

- (NSData * __nullable)decryptThenVerifyBase64String:(NSString * __nonnull)base64String from:(VSSVirgilCard * __nonnull)card error:(NSError * __nullable * __nullable)errorPtr NS_SWIFT_NAME(decryptThenVerify(base64String:from:));

- (NSData * __nullable)decryptThenVerifyBase64String:(NSString * __nonnull)base64String fromOneOf:(NSArray<VSSVirgilCard *> * __nonnull)cards error:(NSError * __nullable * __nullable)errorPtr NS_SWIFT_NAME(decryptThenVerify(base64String:fromOneOf:));

- (BOOL)storeWithName:(NSString * __nonnull)name password:(NSString * __nullable)password error:(NSError * __nullable * __nullable)errorPtr;

- (NSData * __nonnull)exportPublicKey;

/**
 Unavailable no-argument initializer inherited from NSObject
 */
- (instancetype __nonnull)init NS_UNAVAILABLE;

@end
