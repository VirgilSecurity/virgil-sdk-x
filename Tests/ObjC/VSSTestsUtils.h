//
//  VSSTestsUtils.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 10/13/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>

@import VirgilSDK;

#import "VSSTestsConst.h"

@interface VSSTestsUtils : NSObject

@property (nonatomic, readonly) VSSCrypto * __nonnull crypto;
@property (nonatomic, readonly) VSSTestsConst * __nonnull consts;

- (VSSCreateCardRequest * __nonnull)instantiateCreateCardRequest;
- (VSSCreateCardRequest * __nonnull)instantiateCreateCardRequestWithData:(NSDictionary<NSString *, NSString *> * __nonnull)data;
- (VSSRevokeCardRequest * __nonnull)instantiateRevokeCardForCard:(VSSCard * __nonnull)card;
- (BOOL)checkCard:(VSSCard * __nonnull)card isEqualToCreateCardRequest:(VSSCreateCardRequest * __nonnull)request;
- (BOOL)checkCard:(VSSCard * __nonnull)card1 isEqualToCard:(VSSCard * __nonnull)card2;
- (BOOL)checkCreateCardRequest:(VSSCreateCardRequest * __nonnull)request1 isEqualToCreateCardRequest:(VSSCreateCardRequest * __nonnull)request2;
- (BOOL)checkRevokeCardRequest:(VSSRevokeCardRequest * __nonnull)request1 isEqualToRevokeCardRequest:(VSSRevokeCardRequest * __nonnull)request2;
- (NSString * __nonnull)generateEmail;


- (instancetype __nonnull)init NS_UNAVAILABLE;

- (instancetype __nonnull)initWithCrypto:(VSSCrypto * __nonnull)crypto consts:(VSSTestsConst * __nonnull)consts;

@end
