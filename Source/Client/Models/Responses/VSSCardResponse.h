//
//  VSSCardResponse.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 10/27/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSBaseModel.h"
#import "VSSCreateCardSnapshotModel.h"


/**
 Response from Virgil Cards Service with Virgil Card details.
 */
@interface VSSCardResponse : VSSBaseModel

/**
 NSDictionary with NSString Key representing Signature id and NSData Value with Signature.
 */
@property (nonatomic, copy, readonly) NSDictionary<NSString *, NSData *> * __nonnull signatures;

/**
 NSData with Snapshot - raw serialized representation of payload (VSSCard/VSSRevokeCard) which remains unchanged from the moment of creation
 */
@property (nonatomic, copy, readonly) NSData * __nonnull snapshot;

/**
 VSSCreateCardSnapshotModel instanse with deserialized snapshot data, which contains basic Virgil Card data
 */
@property (nonatomic, copy, readonly) VSSCreateCardSnapshotModel * __nonnull model;

/**
 Unique Virgil Card identifier
 */
@property (nonatomic, copy, readonly) NSString * __nonnull identifier;

/**
 Date of Virgil Card creation
 */
@property (nonatomic, copy, readonly) NSDate * __nonnull createdAt;

/**
 Card version
 */
@property (nonatomic, copy, readonly) NSString * __nonnull cardVersion;

/**
 Unavailable no-argument initializer inherited from NSObject
 */
- (instancetype __nonnull)init NS_UNAVAILABLE;

@end
