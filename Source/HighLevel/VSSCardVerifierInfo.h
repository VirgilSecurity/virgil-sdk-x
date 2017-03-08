//
//  VSSCardVerifierInfo.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 3/8/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VSSCardVerifierInfo : NSObject

@property (nonatomic, readonly) NSString * __nonnull cardId;
@property (nonatomic, readonly) NSData * __nonnull publicKeyData;

- (instancetype __nonnull)initWithCardId:(NSString * __nonnull)cardId publicKeyData:(NSData * __nonnull)publicKeyData NS_DESIGNATED_INITIALIZER;

/**
 Unavailable no-argument initializer inherited from NSObject
 */
- (instancetype __nonnull)init NS_UNAVAILABLE;

@end
