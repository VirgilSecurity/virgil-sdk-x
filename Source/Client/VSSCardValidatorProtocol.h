//
//  VSSCardValidatorProtocol.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 10/5/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSCard.h"

/**
 Protocol designed for validation VSSCard instances (using signatures by default)
 */
@protocol VSSCardValidator <NSObject, NSCopying>

/**
 Validated VSSCard genuineness

 @param card VSSCard to be validated

 @return BOOL value which indicates whether validation was successful or failed
 */
- (BOOL)validateCard:(VSSCard * __nonnull)card;

@end
