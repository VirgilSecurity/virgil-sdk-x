//
//  VSSKeysManagerPrivate.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 2/28/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

#import "VSSKeysManager.h"
#import "VSSVIrgilApiContext.h"

@interface VSSKeysManager ()

@property (nonatomic, readonly) VSSVirgilApiContext * __nonnull context;

- (instancetype __nonnull)initWithContext:(VSSVirgilApiContext * __nonnull)context NS_DESIGNATED_INITIALIZER;

@end
