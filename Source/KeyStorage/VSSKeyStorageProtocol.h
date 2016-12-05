//
//  VSSKeyStorageProtocol.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 11/1/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VSSKeyEntry.h"

@protocol VSSKeyStorage <NSObject>

- (BOOL)storeKeyEntry:(VSSKeyEntry * __nonnull)keyEntry error:(NSError * __nullable * __nullable)errorPtr;

- (VSSKeyEntry * __nullable)loadKeyEntryWithName:(NSString * __nonnull)name error:(NSError * __nullable * __nullable)errorPtr;

- (BOOL)existsKeyEntryWithName:(NSString * __nonnull)name;

- (BOOL)deleteKeyEntryWithName:(NSString * __nonnull)name error:(NSError * __nullable * __nullable)errorPtr;

@end
