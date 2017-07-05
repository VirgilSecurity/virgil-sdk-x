//
//  VSSVirgilCard.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 11/8/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VSSModelCommons.h"
#import "VSSCreateCardRequest.h"
#import "VSSRevokeCardRequest.h"
#import "VSSExportable.h"
#import "VSSCard.h"

#undef verify

/**
 Class representing Virgil Card.
 */
@interface VSSVirgilCard : NSObject <VSSExportable>

/**
 NSString with Virgil Card identifier.
 */
@property (nonatomic, readonly) NSString * __nonnull identifier;

/**
 NSString with identity value.
 */
@property (nonatomic, readonly) NSString * __nonnull identity;

/**
 NSString with identity type.
 */
@property (nonatomic, readonly) NSString * __nonnull identityType;

/**
 NSDictionary with custom payload if used on creation.
 */
@property (nonatomic, readonly) NSDictionary<NSString *, NSString *> * __nullable customFields;

/**
 NSDictionary with info about device on which Virgil Card was created.
 */
@property (nonatomic, readonly) NSDictionary<NSString *, NSString *> * __nullable info;

/**
 Virgil Card's scope. Either Application or Global.
 See VSSCardScope.
 */
@property (nonatomic, readonly) VSSCardScope scope;

/**
 YES if card was published on the Virgil Service, NO otherwise.
 */
@property (nonatomic, readonly) BOOL isPublished;

/**
 Encrypts data for Virgil Card owner.

 @param data NSData with data to be encrypted
 @param errorPtr NSError pointer to return error if needed
 @return NSData with encrypted data
 */
- (NSData * __nullable)encryptData:(NSData * __nonnull)data error:(NSError * __nullable * __nullable)errorPtr NS_SWIFT_NAME(encrypt(_:));

/**
 Encrypts string for Virgil Card owner.
 NOTE: string is converted to binary representation using UTF8 encoding.

 @param string NSString with string to be encrypted
 @param errorPtr NSError pointer to return error if needed
 @return NSData with encrypted string
 */
- (NSData * __nullable)encryptString:(NSString * __nonnull)string error:(NSError * __nullable * __nullable)errorPtr NS_SWIFT_NAME(encrypt(_:));

/**
 Verifies data using signature.

 @param data NSData with data to be verified
 @param signature NSData with signature
 @param errorPtr NSError pointer to return error if needed
 @return YES if verification succeeded, NO otherwise
 */
- (BOOL)verifyData:(NSData * __nonnull)data withSignature:(NSData * __nonnull)signature error:(NSError * __nullable * __nullable)errorPtr NS_SWIFT_NAME(verify(_:withSignature:));

/**
 Verifies data using signature.
 NOTE: string is converted to binary representation using UTF8 encoding.
 
 @param string NSData with string to be verified
 @param signature NSData with signature
 @param errorPtr NSError pointer to return error if needed
 @return YES if verification succeeded, NO otherwise
 */
- (BOOL)verifyString:(NSString * __nonnull)string withSignature:(NSData * __nonnull)signature error:(NSError * __nullable * __nullable)errorPtr NS_SWIFT_NAME(verify(_:withSignature:));

/**
 Getter for underlying low-level api VSSCard instance.
 */
@property (nonatomic, readonly) VSSCard * __nullable card;

/**
 Getter for underlying low-level api VSSCreateCardRequest isntance.
 */
@property (nonatomic, readonly) VSSCreateCardRequest * __nullable request;

/**
 Unavailable no-argument initializer inherited from NSObject
 */
- (instancetype __nonnull)init NS_UNAVAILABLE;

@end
