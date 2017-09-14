//
//  VSSAuthClient.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 5/23/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VSSChallengeMessageResponse.h"
#import "VSSObtainTokenResponse.h"
#import "VSSAuthServiceConfig.h"

/**
 Client used for all interactions with Virgil Auth Services.
 */
@interface VSSAuthClient : VSSBaseClient

/**
 VSSAuthServiceConfig instance, which contains the information needed to interract with Virgil Auth Services such as service URLs, public keys.
 */
@property (nonatomic, copy, readonly) VSSAuthServiceConfig * __nonnull serviceConfig;

/**
 Designated constructor.
 
 @param serviceConfig VSSServiceConfig instance containing the service configuration.
 
 @return initialized VSSClient instance
 */
- (instancetype __nonnull)initWithAuthServiceConfig:(VSSAuthServiceConfig * __nonnull)serviceConfig NS_DESIGNATED_INITIALIZER;

/**
 Convenient constructor.
 This constructor initialized VSSAuthClient instance with production Auth Service Public Key and URL.
 
 @return initialized VSSAuthClient instance
 */
- (instancetype __nonnull)init;

/**
 Requests challenge message from Virgil Auth Service to obtain access token.
 
 @param virgilCardId NSString with id of virgil card for which token will be granted
 @param callback callback with VSSChallengeMessageResponse object, or NSError instance if error occured
 */
- (void)getChallengeMessageForVirgilCardWithId:(NSString * __nonnull)virgilCardId completion:(void (^ __nonnull)(VSSChallengeMessageResponse * __nullable, NSError * __nullable))callback;

/**
 Acknowledges using auth grant id and reencrypted message. Message should be reencrypted for Virgil Auth Service whose public key can be found in VSSClient.m.
 
 @param authGrantId NSString auth grant id which can be found in VSSChallengeMessageResponse
 @param encryptedMessage Reencrypted for Virgil Auth Service message. Original message can be found inside VSSChallengeMessageResponse
 @param callback callback with access code, or NSError instance if error occured
 */
- (void)ackChallengeMessageWithAuthGrantId:(NSString * __nonnull)authGrantId encryptedMessage:(NSData * __nonnull)encryptedMessage completion:(void (^ __nonnull)(NSString * __nullable, NSError * __nullable))callback;

/**
 Obtaines access and refresh tokens using access code.
 
 @param accessCode NSString with access code
 @param callback callback with VSSObtainTokenResponse object, or NSError instance if error occured
 */
- (void)obtainAccessTokenWithAccessCode:(NSString * __nonnull)accessCode completion:(void (^ __nonnull)(VSSObtainTokenResponse * __nullable, NSError * __nullable))callback;

/**
 Refreshes access token using refresh token
 
 @param refreshToken NSString with refresh token
 @param callback callback with VSSTokenResponse object, or NSError instance if error occured
 */
- (void)refreshAccessTokenWithRefreshToken:(NSString * __nonnull)refreshToken completion:(void (^ __nonnull)(VSSTokenResponse * __nullable, NSError * __nullable))callback;

/**
 Verifies access token.
 
 @param accessToken NSString with access token
 @param callback callback with virgil card id of token owner, or NSError instance if error occured
 */
- (void)verifyAccessToken:(NSString * __nonnull)accessToken completion:(void (^ __nonnull)(NSString * __nullable, NSError * __nullable))callback;

@end
