//
//  VSSRequestExtended.h
//  VirgilKeys
//
//  Created by Pavel Gorb on 2/10/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSRequest.h"

@class VSSRequestContextExtended;

@interface VSSRequestExtended : VSSRequest

- (NSError * __nullable)sign;
- (NSError * __nullable)verify;
- (NSError * __nullable)encrypt;
- (NSError * __nullable)decrypt;

- (VSSRequestContextExtended * __nullable)extendedContext;

@end
