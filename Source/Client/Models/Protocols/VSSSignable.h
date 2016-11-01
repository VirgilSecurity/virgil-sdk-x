//
//  VSSSignable.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 10/28/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

/**
 Protocol for classes that can be signed. See VSSSignableRequest
 */
@protocol VSSSignable <NSObject>

/**
 Data which can be signed
 */
@property (nonatomic, copy, readonly) NSData * __nonnull snapshot;

/**
 Adds signature to data.
 
 @param signature   NSData with Signature
 @param fingerprint NSString which identifies Signature
 */
- (void)addSignature:(NSData * __nonnull)signature forFingerprint:(NSString * __nonnull)fingerprint;

@end
