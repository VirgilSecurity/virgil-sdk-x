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

/**
 Base class for all Virgil Models that can be Signed, Imported and Exported.
 See VSSBaseModel, VSSImportable, VSSExportable.
 */
@interface VSSSignedData : VSSBaseModel <VSSImportable, VSSExportable>

/**
 NSDictionary with NSString Key representing Signature id and NSData Value with Signature.
 */
@property (nonatomic, copy, readonly) NSDictionary<NSString *, NSData *> * __nonnull signatures;

/**
 NSString with Virgil Card version.
 Will be nil for all instances except registered VSSCard instances.
 */
@property (nonatomic, copy, readonly) NSString * __nullable cardVersion;

/**
 NSDate with date of creation of Virgil Card.
 Will be nil for all instances except registered VSSCard instances.
 */
@property (nonatomic, copy, readonly) NSDate * __nullable createdAt;

/**
 NSString with Identifier of Virgil Card
 */
@property (nonatomic, copy, readonly) NSString * __nullable identifier;

/**
 NSData with Snapshot - raw serialized representation of payload (VSSCard/VSSRevokeCard) which remains unchanged from the moment of creation
 */
@property (nonatomic, copy, readonly) NSData * __nonnull snapshot;

/**
 Unavailable no-argument initializer inherited from NSObject
 */
- (instancetype __nonnull)init NS_UNAVAILABLE;

/**
 Adds signature to data.

 @param signature   NSData with Signature
 @param fingerprint NSString which identifies Signature
 */
- (void)addSignature:(NSData * __nonnull)signature forFingerprint:(NSString * __nonnull)fingerprint;

@end
