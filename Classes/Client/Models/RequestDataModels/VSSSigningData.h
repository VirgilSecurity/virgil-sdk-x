//
//  VSSSigningRequestData.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 9/23/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSRequestData.h"
#import "VSSSerializable.h"
#import "VSSDeserializable.h"

@interface VSSSigningData : VSSRequestData <VSSSerializable, VSSDeserializable>

@property (nonatomic, copy, readonly) NSDictionary * __nonnull signatures;

- (instancetype __nonnull)initWithSignatures:(NSDictionary * __nullable)signatures NS_DESIGNATED_INITIALIZER;

- (void)addSignature:(NSString * __nonnull)signature forFingerprint:(NSString * __nonnull)fingerprint;

@end
