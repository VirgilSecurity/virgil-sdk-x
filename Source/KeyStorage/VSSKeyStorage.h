//
//  VSSKeyStorage.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 11/2/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSKeyStorageProtocol.h"
#import "VSSKeyStorageConfiguration.h"

extern NSString * __nonnull const kVSSKeyStorageErrorDomain;

@interface VSSKeyStorage : NSObject <VSSKeyStorage>

@property (nonatomic, copy, readonly) VSSKeyStorageConfiguration * __nonnull configuration;

- (instancetype __nonnull)initWithConfiguration:(VSSKeyStorageConfiguration * __nonnull)configuration NS_DESIGNATED_INITIALIZER;

- (instancetype __nonnull)initWithApplicationName:(NSString * __nonnull)applicationName;

@end
