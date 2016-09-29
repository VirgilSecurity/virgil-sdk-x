//
//  VSSSigningRequestData.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 9/23/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSBaseModel.h"

@interface VSSSignedData : VSSBaseModel

@property (nonatomic, copy, readonly) NSDictionary * __nonnull signatures;
@property (nonatomic, copy, readonly) NSString * __nullable cardVersion;
@property (nonatomic, copy, readonly) NSDate * __nullable createdAt;

- (instancetype __nonnull)init NS_UNAVAILABLE;

- (void)addSignature:(NSString * __nonnull)signature forFingerprint:(NSString * __nonnull)fingerprint;

@end
