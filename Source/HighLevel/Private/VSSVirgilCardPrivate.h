//
//  VSSVirgilCardPrivate.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 11/8/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSVirgilCard.h"
#import "VSSCard.h"
#import "VSSCreateCardRequest.h"
#import "VSSVirgilApiContext.h"

@interface VSSVirgilCard ()

@property (nonatomic, readonly) VSSVirgilApiContext * __nonnull context;
@property (nonatomic) VSSCard * __nullable card;
@property (nonatomic, readonly) VSSCreateCardRequest * __nullable request;
@property (nonatomic, readonly) NSString * __nullable calculatedIdentifier;
@property (nonatomic, readonly) VSSPublicKey * __nonnull publicKey;

- (instancetype __nonnull)initWithContext:(VSSVirgilApiContext * __nonnull)context request:(VSSCreateCardRequest * __nonnull)request NS_DESIGNATED_INITIALIZER;

- (instancetype __nonnull)initWithContext:(VSSVirgilApiContext * __nonnull)context card:(VSSCard * __nonnull)card NS_DESIGNATED_INITIALIZER;

- (instancetype __nullable)initWithContext:(VSSVirgilApiContext * __nonnull)context data:(NSString * __nonnull)data;

- (void)publishWithCompletion:(void (^ __nonnull)(NSError * __nullable))callback;

@end
