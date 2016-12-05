//
//  VSSCryptoCommons.m
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 11/11/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSCryptoCommonsPrivate.h"

VSCKeyType vss_mapKeyType(VSSKeyType type) {
    switch (type) {
        case VSSKeyTypeRSA_256: return VSCKeyTypeRSA_256;
        case VSSKeyTypeRSA_512: return VSCKeyTypeRSA_512;
        case VSSKeyTypeRSA_1024: return VSCKeyTypeRSA_1024;
        case VSSKeyTypeRSA_2048: return VSCKeyTypeRSA_2048;
        case VSSKeyTypeRSA_3072: return VSCKeyTypeRSA_3072;
        case VSSKeyTypeRSA_4096: return VSCKeyTypeRSA_4096;
        case VSSKeyTypeRSA_8192: return VSCKeyTypeRSA_8192;
        case VSSKeyTypeEC_SECP192R1: return VSCKeyTypeEC_SECP192R1;
        case VSSKeyTypeEC_SECP224R1: return VSCKeyTypeEC_SECP224R1;
        case VSSKeyTypeEC_SECP256R1: return VSCKeyTypeEC_SECP256R1;
        case VSSKeyTypeEC_SECP384R1: return VSCKeyTypeEC_SECP384R1;
        case VSSKeyTypeEC_SECP521R1: return VSCKeyTypeEC_SECP521R1;
        case VSSKeyTypeEC_BP256R1: return VSCKeyTypeEC_BP256R1;
        case VSSKeyTypeEC_BP384R1: return VSCKeyTypeEC_BP384R1;
        case VSSKeyTypeEC_BP512R1: return VSCKeyTypeEC_BP512R1;
        case VSSKeyTypeEC_SECP192K1: return VSCKeyTypeEC_SECP192K1;
        case VSSKeyTypeEC_SECP224K1: return VSCKeyTypeEC_SECP224K1;
        case VSSKeyTypeEC_SECP256K1: return VSCKeyTypeEC_SECP256K1;
        case VSSKeyTypeEC_CURVE25519: return VSCKeyTypeEC_CURVE25519;
        case VSSKeyTypeFAST_EC_X25519: return VSCKeyTypeFAST_EC_X25519;
        case VSSKeyTypeFAST_EC_ED25519: return VSCKeyTypeFAST_EC_ED25519;
    }
}
