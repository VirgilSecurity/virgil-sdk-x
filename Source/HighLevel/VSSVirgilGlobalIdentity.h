//
//  VSSVirgilGlobalIdentity.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 3/3/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

#import "VSSVirgilIdentity.h"

@interface VSSVirgilGlobalIdentity : VSSVirgilIdentity

- (void)checkWithOptions:(NSDictionary<NSString *, NSString *> * __nullable)options completion:(void (^ __nonnull)(NSError * __nullable))callback;

- (void)confirmWithConfirmationCode:(NSString * __nonnull)code completion:(void (^ __nonnull)(NSError * __nullable))callback;

@end
