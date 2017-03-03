//
//  VSSCredentialsProtocol.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 3/3/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

#import "VSSPrivateKey.h"

@protocol VSSCredentials <NSObject>

@property (nonatomic, readonly) VSSPrivateKey * __nullable appKey;
@property (nonatomic, readonly) NSString * __nullable appId;

@end
