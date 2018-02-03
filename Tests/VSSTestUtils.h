//
//  VSSTestUtils.h
//  VirgilSDK
//
//  Created by Eugen Pivovarov on 1/29/18.
//  Copyright © 2018 VirgilSecurity. All rights reserved.
//

#ifndef VSSTestUtils_h
#define VSSTestUtils_h

#import "VSSTestsConst.h"

@import VirgilSDK;
@import VirgilCryptoApiImpl;

@interface VSSTestUtils : NSObject

@property (nonatomic) VSMVirgilCrypto * __nonnull crypto;
@property (nonatomic) VSSTestsConst * __nonnull consts;

- (VSSRawSignedModel * __nonnull)instantiateRawSignedModelWithKeyPair:(VSMVirgilKeyPair * __nullable)keyPair identity:(NSString *_Nullable)identity error:(NSError * __nullable * __nullable)errorPtr;

- (NSString * __nonnull)getTokenStringWithIdentity:(NSString * __nonnull)identity error:(NSError * __nullable * __nullable)errorPtr;
- (id<VSSAccessToken> __nonnull)getTokenWithIdentity:(NSString * __nonnull)identity ttl:(NSTimeInterval)ttl error:(NSError * __nullable * __nullable)errorPtr;
- (NSString * __nonnull)getTokenWithWrongPrivateKeyWithIdentity:(NSString * __nonnull)identity error:(NSError * __nullable * __nullable)errorPtr;

-(VSSGeneratorJwtProvider * __nonnull)getGeneratorJwtProviderWithIdentity:(NSString * __nonnull)identity error:(NSError * __nullable * __nullable)errorPtr;

-(NSData * __nonnull)getRandomData;

-(BOOL)isCardsEqualWithCard:(VSSCard * __nonnull)card1 and:(VSSCard * __nonnull)card2;
-(BOOL)isRawCardContentEqualWithContent:(VSSRawCardContent * __nonnull)content1 and:(VSSRawCardContent * __nonnull)content2;
-(BOOL)isRawSignaturesEqualWithSignature:(VSSRawSignature * __nonnull)signature1 and:(VSSRawSignature * __nonnull)signature2;
-(BOOL)isCardSignaturesEqualWithSignature:(VSSCardSignature * __nonnull)signature1 and:(VSSCardSignature * __nonnull)signature2;
-(BOOL)isRawSignaturesEqualWithSignatures:(NSArray<VSSRawSignature *> * __nonnull)signatures1 and:(NSArray<VSSRawSignature *> * __nonnull)signatures2;
-(BOOL)isCardSignaturesEqualWithSignatures:(NSArray<VSSCardSignature *> * __nonnull)signatures1 and:(NSArray<VSSCardSignature *> * __nonnull)signatures2;

-(VSSRawSignature * __nullable)getSelfSignatureFromModel:(VSSRawSignedModel * __nonnull)rawCard;
-(VSSCardSignature * __nullable)getSelfSignatureFromCard:(VSSCard * __nonnull)card;

- (instancetype __nonnull)initWith NS_UNAVAILABLE;

- (instancetype __nonnull)initWithCrypto:(VSMVirgilCrypto * __nonnull)crypto consts:(VSSTestsConst * __nonnull)consts;

@end

#endif /* VSSTestUtils_h */
