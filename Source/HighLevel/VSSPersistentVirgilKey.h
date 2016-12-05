//
//  VSSPersistentVirgilKey.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 11/11/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSVirgilKey.h"

@interface VSSPersistentVirgilKey : VSSVirgilKey

+ (instancetype __nullable)loadPersistentVirgilKeyWithName:(NSString * __nonnull)name password:(NSString * __nullable)password error:(NSError * __nullable * __nullable)errorPtr;

- (BOOL)destroyWithError:(NSError * __nullable * __nullable)errorPtr;

@end
