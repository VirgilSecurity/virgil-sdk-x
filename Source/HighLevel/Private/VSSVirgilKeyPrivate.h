//
//  VSSVirgilKeyPrivate.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 2/14/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

#import "VSSVirgilKey.h"
#import "VSSVirgilApiContext.h"
#import "VSSPrivateKey.h"

@interface VSSVirgilKey ()

@property (nonatomic, readonly) VSSVirgilApiContext * __nonnull context;

- (instancetype __nonnull)initWithContext:(VSSVirgilApiContext * __nonnull)context privateKey:(VSSPrivateKey * __nonnull)privateKey NS_DESIGNATED_INITIALIZER;

@end
