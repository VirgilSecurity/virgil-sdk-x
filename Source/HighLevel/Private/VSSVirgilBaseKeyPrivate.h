//
//  VSSVirgilBaseKeyPrivate.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 11/10/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSVirgilBaseKey.h"
#import "VSSKeyPair.h"

@interface VSSVirgilBaseKey ()

@property (nonatomic) VSSKeyPair * __nonnull keyPair;

- (instancetype __nonnull)initWithKeyPair:(VSSKeyPair * __nonnull)keyPair NS_DESIGNATED_INITIALIZER;

@end
