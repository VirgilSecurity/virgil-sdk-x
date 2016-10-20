//
//  VSSCryptoPrivate.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 10/3/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSCrypto.h"

@interface VSSCrypto ()

- (NSData * __nonnull)computeHashForPublicKey:(NSData * __nonnull)publicKey;

@end
