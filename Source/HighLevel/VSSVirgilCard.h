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

@interface VSSVirgilCard : NSObject

/**
 Unavailable no-argument initializer inherited from NSObject
 */
- (instancetype __nonnull)init NS_UNAVAILABLE;

@property (nonatomic, readonly) NSString * __nonnull identifier;
@property (nonatomic, readonly) NSString * __nonnull identity;
@property (nonatomic, readonly) NSString * __nonnull identityType;
@property (nonatomic, readonly) NSDictionary<NSString *, NSString *> * __nullable data;
@property (nonatomic, readonly) NSData * __nonnull publicKey;
@property (nonatomic, readonly) NSDictionary<NSString *, NSString *> * __nullable info;
@property (nonatomic, readonly) VSSCardScope scope;

- (NSData * __nonnull)encryptData:(NSData * __nonnull)data error:(NSError * __nullable * __nullable)errorPtr;

- (BOOL)verifyData:(NSData * __nonnull)data withSignature:(NSData * __nonnull)signature error:(NSError * __nullable * __nullable)errorPtr;

//public string Export()

@end
