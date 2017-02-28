//
//  VSSKeysManagerProtocol.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 2/13/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

#import "VSSVirgilKey.h"

@protocol VSSKeysManager <NSObject>

- (VSSVirgilKey * __nonnull)generateKey;

- (VSSVirgilKey * __nullable)loadKeyWithName:(NSString * __nonnull)name password:(NSString * __nullable)password error:(NSError * __nullable * __nullable)errorPtr;

- (VSSVirgilKey * __nullable)importKeyFromData:(NSData * __nonnull)data password:(NSString * __nullable)password;

- (BOOL)destroyKeyWithName:(NSString * __nonnull)name error:(NSError * __nullable * __nullable)errorPtr;

@end
