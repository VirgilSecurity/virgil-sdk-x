//
//  VSSIdentitiesManagerPrivate.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 3/3/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

#import "VSSIdentitiesManager.h"
#import "VSSVirgilApiContext.h"

@interface VSSIdentitiesManager ()

@property (nonatomic, readonly) VSSVirgilApiContext * __nonnull context;

- (instancetype __nonnull)initWithContext:(VSSVirgilApiContext * __nonnull)context NS_DESIGNATED_INITIALIZER;

@end
