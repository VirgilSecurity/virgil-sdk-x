//
//  VSSPublicKeyExtended.h
//  VirgilKeys
//
//  Created by Pavel Gorb on 2/5/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSPublicKey.h"

@class VSSCard;

@interface VSSPublicKeyExtended : VSSPublicKey

/// The array with Virgil Card entities attached to (or associated with) this public key at the Virgil Keys Service.
@property (nonatomic, copy, readonly) NSArray <VSSCard *>* __nonnull cards;

- (instancetype __nonnull)initWithId:(GUID * __nonnull)Id createdAt:(NSDate * __nullable)createdAt key:(NSData * __nonnull)key cards:(NSArray <VSSCard*>* __nonnull)cards NS_DESIGNATED_INITIALIZER;

@end
