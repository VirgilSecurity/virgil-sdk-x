//
//  VSSPrivateKey.h
//  VirgilKeys
//
//  Created by Pavel Gorb on 1/29/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSBaseModel.h"
#import "VSSPublicKey.h"

/**
 * Wrapper object for user's private key. Similarly to VSSPublicKey contains actual private key data.
 * Also might contain the password which was used to protect the private key.
 */
@interface VSSPrivateKey : VSSBaseModel

- (instancetype __nonnull)init NS_UNAVAILABLE;

@end
