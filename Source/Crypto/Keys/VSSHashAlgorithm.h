//
//  VSSHashAlgorithm.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 9/27/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

/**
 Enum with possible algorithm for calculating hash.
 See VSSCrypto protocol

 - VSSHashAlgorithmMD5:    md5
 - VSSHashAlgorithmSHA1:   sha1
 - VSSHashAlgorithmSHA224: sha224
 - VSSHashAlgorithmSHA256: sha256
 - VSSHashAlgorithmSHA384: sha384
 - VSSHashAlgorithmSHA512: sha512
 */
typedef NS_ENUM(NSInteger, VSSHashAlgorithm) {
    VSSHashAlgorithmMD5,
    VSSHashAlgorithmSHA1,
    VSSHashAlgorithmSHA224,
    VSSHashAlgorithmSHA256,
    VSSHashAlgorithmSHA384,
    VSSHashAlgorithmSHA512
};
