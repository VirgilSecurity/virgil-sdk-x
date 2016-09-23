//
//  VSSSigningRequestData.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 9/23/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSRequestData.h"

@interface VSSSigningRequestData : VSSRequestData

@property (nonatomic, copy, readonly) NSDictionary<NSString *, NSString *> * __nonnull signs;

- (void)addSignature:(NSString * __nonnull)signature forFingerprint:(NSString * __nonnull)fingerprint;

@end
