//
//  VSSVirgilCard.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 11/8/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "VSSModelCommons.h"

#import "VSSCreateCardRequest.h"
#import "VSSRevokeCardRequest.h"

@interface VSSVirgilCard : NSObject

/**
 Unavailable no-argument initializer inherited from NSObject
 */
- (instancetype __nonnull)init NS_UNAVAILABLE;

@property (nonatomic, readonly) NSString * __nonnull identifier;
@property (nonatomic, readonly) NSString * __nonnull identity;
@property (nonatomic, readonly) NSString * __nonnull identityType;
@property (nonatomic, readonly) NSDictionary<NSString *, NSString *> * __nullable data;
@property (nonatomic, readonly) NSData * __nonnull publicKey;
@property (nonatomic, readonly) NSDictionary<NSString *, NSString *> * __nullable info;
@property (nonatomic, readonly) VSSCardScope scope;

- (NSData * __nonnull)encryptData:(NSData * __nonnull)data error:(NSError * __nullable * __nullable)errorPtr;

- (BOOL)verifyData:(NSData * __nonnull)data withSignature:(NSData * __nonnull)signature error:(NSError * __nullable * __nullable)errorPtr;

+ (void)getCardWithId:(NSString * __nonnull)cardId completion:(void (^ __nonnull)(VSSVirgilCard * __nullable, NSError * __nullable))callback NS_SWIFT_NAME(getCard(withId:completion:));

+ (void)searchGlobalCardsWithIdentity:(NSString * __nonnull)identity identityType:(VSSGlobalIdentityType)type completion:(void (^ __nonnull)(NSArray<VSSVirgilCard *>* __nullable, NSError * __nullable))callback NS_SWIFT_NAME(searchGlobalCards(withIdentity:identityType:completion:));

+ (void)searchGlobalCardsWithIdentities:(NSArray<NSString *> * __nonnull)identities identityType:(VSSGlobalIdentityType)type completion:(void (^ __nonnull)(NSArray<VSSVirgilCard *>* __nullable, NSError * __nullable))callback NS_SWIFT_NAME(searchGlobalCards(withIdentity:identityType:completion:));

+ (void)searchCardsWithIdentity:(NSString * __nonnull)identity identityType:(NSString * __nonnull)type completion:(void (^ __nonnull)(NSArray<VSSVirgilCard *>* __nullable, NSError * __nullable))callback NS_SWIFT_NAME(searchCards(withIdentity:identityType:completion:));

+ (void)searchCardsWithIdentities:(NSArray<NSString *> * __nonnull)identities identityType:(NSString * __nonnull)type completion:(void (^ __nonnull)(NSArray<VSSVirgilCard *>* __nullable, NSError * __nullable))callback NS_SWIFT_NAME(searchCards(withIdentities:identityType:completion:));

+ (void)createCardWithRequest:(VSSCreateCardRequest * __nonnull)request completion:(void (^ __nonnull)(VSSVirgilCard * __nullable, NSError * __nullable))callback NS_SWIFT_NAME(createCardWith(_:completion:));

+ (void)revokeCardWithRequest:(VSSRevokeCardRequest* __nonnull)request completion:(void (^ __nonnull)(NSError * __nullable))callback NS_SWIFT_NAME(revokeCardWith(_:completion:));

@end
