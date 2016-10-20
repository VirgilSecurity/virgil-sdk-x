//
//  VSSSigningRequestData.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 9/23/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSBaseModel.h"
#import "VSSImportable.h"
#import "VSSExportable.h"

@interface VSSSignedData : VSSBaseModel <VSSImportable, VSSExportable>

@property (nonatomic, copy, readonly) NSDictionary<NSString *, NSData *> * __nonnull signatures;
@property (nonatomic, copy, readonly) NSString * __nullable cardVersion;
@property (nonatomic, copy, readonly) NSDate * __nullable createdAt;

@property (nonatomic, copy, readonly) NSString * __nullable identifier;

@property (nonatomic, copy, readonly) NSData * __nonnull snapshot;

- (instancetype __nonnull)init NS_UNAVAILABLE;

- (void)addSignature:(NSData * __nonnull)signature forFingerprint:(NSString * __nonnull)fingerprint;

@end
