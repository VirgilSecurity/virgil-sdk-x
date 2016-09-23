//
//  VSSCreationRequestData.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 9/23/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSSigningRequestData.h"
#import "VSSPublicKey.h"

@interface VSSCreationRequestData : VSSSigningRequestData

@property (nonatomic, copy, readonly) NSString * __nonnull identityType;
@property (nonatomic, copy, readonly) NSString * __nonnull identity;
@property (nonatomic, copy, readonly) NSString * __nonnull publicKey;

@property (nonatomic, copy, readonly) NSString * __nullable device;
@property (nonatomic, copy, readonly) NSString * __nullable deviceName;

- (instancetype __nonnull)initWithIdentity:(NSString * __nonnull)identity ofIdentityType:(NSString * __nonnull)identityType publicKey:(VSSPublicKey * __nonnull)publicKey;

@end
