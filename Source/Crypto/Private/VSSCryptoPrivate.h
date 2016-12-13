//
//  VSSCryptoPrivate.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 10/3/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSCrypto.h"
@import VirgilCrypto;

@interface VSSCrypto ()

- (VSSKeyPair * __nonnull)wrapCryptoKeyPair:(VSCKeyPair * __nonnull)keyPair;

- (NSData * __nonnull)computeHashForPublicKeyData:(NSData * __nonnull)publicKeyData;

@end
