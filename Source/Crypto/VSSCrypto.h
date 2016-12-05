//
//  VSSCrypto.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 9/29/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSCryptoProtocol.h"
#import "VSSCryptoCommons.h"

/**
 VSSCrypto protocol default implementation. See VSSCrypto protocol.
 */
@interface VSSCrypto : NSObject <VSSCrypto>

- (VSSKeyPair * __nonnull)generateKeyPairOfType:(VSSKeyType)type;

@end
