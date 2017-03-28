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

#undef verify

@interface VSSVirgilCard : NSObject <VSSExportable>

/**
 Unavailable no-argument initializer inherited from NSObject
 */
- (instancetype __nonnull)init NS_UNAVAILABLE;

@property (nonatomic, readonly) NSString * __nonnull identifier;
@property (nonatomic, readonly) NSString * __nonnull identity;
@property (nonatomic, readonly) NSString * __nonnull identityType;
@property (nonatomic, readonly) NSDictionary<NSString *, NSString *> * __nullable customFields;
@property (nonatomic, readonly) NSDictionary<NSString *, NSString *> * __nullable info;
@property (nonatomic, readonly) VSSCardScope scope;
@property (nonatomic, readonly) BOOL isPublished;

- (NSData * __nullable)encryptData:(NSData * __nonnull)data error:(NSError * __nullable * __nullable)errorPtr NS_SWIFT_NAME(encrypt(_:));
- (NSData * __nullable)encryptString:(NSString * __nonnull)string error:(NSError * __nullable * __nullable)errorPtr NS_SWIFT_NAME(encrypt(_:));

- (BOOL)verifyData:(NSData * __nonnull)data withSignature:(NSData * __nonnull)signature error:(NSError * __nullable * __nullable)errorPtr NS_SWIFT_NAME(verify(_:withSignature:));
- (BOOL)verifyString:(NSString * __nonnull)string withSignature:(NSData * __nonnull)signature error:(NSError * __nullable * __nullable)errorPtr NS_SWIFT_NAME(verify(_:withSignature:));

@end
