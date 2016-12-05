//
//  VSSCryptoCommons.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 11/11/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, VSSKeyType) {
    VSSKeyTypeRSA_256, ///< RSA 1024 bit (not recommended)
    VSSKeyTypeRSA_512, ///< RSA 1024 bit (not recommended)
    VSSKeyTypeRSA_1024, ///< RSA 1024 bit (not recommended)
    VSSKeyTypeRSA_2048, ///< RSA 2048 bit (not recommended)
    VSSKeyTypeRSA_3072, ///< RSA 3072 bit
    VSSKeyTypeRSA_4096, ///< RSA 4096 bit
    VSSKeyTypeRSA_8192, ///< RSA 8192 bit
    VSSKeyTypeEC_SECP192R1, ///< 192-bits NIST curve
    VSSKeyTypeEC_SECP224R1, ///< 224-bits NIST curve
    VSSKeyTypeEC_SECP256R1, ///< 256-bits NIST curve
    VSSKeyTypeEC_SECP384R1, ///< 384-bits NIST curve
    VSSKeyTypeEC_SECP521R1, ///< 521-bits NIST curve
    VSSKeyTypeEC_BP256R1, ///< 256-bits Brainpool curve
    VSSKeyTypeEC_BP384R1, ///< 384-bits Brainpool curve
    VSSKeyTypeEC_BP512R1, ///< 512-bits Brainpool curve
    VSSKeyTypeEC_SECP192K1, ///< 192-bits "Koblitz" curve
    VSSKeyTypeEC_SECP224K1, ///< 224-bits "Koblitz" curve
    VSSKeyTypeEC_SECP256K1, ///< 256-bits "Koblitz" curve
    VSSKeyTypeEC_CURVE25519, ///< Curve25519 as ECP deprecated format
    VSSKeyTypeFAST_EC_X25519,  ///< Curve25519
    VSSKeyTypeFAST_EC_ED25519, ///< Ed25519
};
