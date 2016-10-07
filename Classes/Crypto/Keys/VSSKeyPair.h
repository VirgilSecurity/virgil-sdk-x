//
//  VSSKeyPair.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 9/27/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSBaseModel.h"
#import "VSSPublicKey.h"
#import "VSSPrivateKey.h"

@interface VSSKeyPair : VSSBaseModel

@property (nonatomic, copy, readonly) VSSPublicKey * __nonnull publicKey;
@property (nonatomic, copy, readonly) VSSPrivateKey * __nonnull privateKey;

- (instancetype __nonnull)init NS_UNAVAILABLE;

@end
