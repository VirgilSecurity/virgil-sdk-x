//
//  VSSCardValidatorProtocol.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 10/5/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSCard.h"

@protocol VSSCardValidator <NSObject, NSCopying>

- (BOOL)validateCard:(VSSCard * __nonnull)card;

@end
