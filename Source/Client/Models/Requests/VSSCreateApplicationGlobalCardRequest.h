//
//  VSSCreateApplicationGlobalCardRequest.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 3/27/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

#import "VSSCreateCardRequest.h"
#import "VSSCreateCardSnapshotModel.h"

extern NSString * __nonnull const kVSSCardIdentityTypeApplication;

/**
 Virgil Model representing request for Virgil Card creation for applications.
 See VSSSignableRequest, VSSCreateCardSnapshotModel. See VSSClient protocol.
 */
@interface VSSCreateApplicationGlobalCardRequest: VSSCreateCardRequest
    
/**
 Factory method which allocates and initalizes VSSCreateCardRequest instance.
 
 @param identity      NSString with Identity that represents Virgil Card within same Identity Type
 @param publicKeyData NSData with Virgil Card public key
 @param data          NSDictionary with custom payload
 
 @return allocated and initialized VSSCreateCardRequest instance
 */
+ (instancetype __nonnull)createApplicationCardRequestWithIdentity:(NSString * __nonnull)identity publicKeyData:(NSData * __nonnull)publicKeyData data:(NSDictionary<NSString *, NSString *> * __nullable)data;
    
@end
