//
//  VSSCardValidatorProtocol.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 10/5/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSCardResponse.h"

/**
 Protocol designed for validation VSSCreateCardRequest instances (using signatures by default)
 */
@protocol VSSCardValidator <NSObject, NSCopying>

/**
 Validated VSSCardResponse genuineness

 @param cardResponse VSSCardResponse to be validated
 @return BOOL value which indicates whether validation was successful or failed
 */
- (BOOL)validateCardResponse:(VSSCardResponse* __nonnull)cardResponse;

@end
