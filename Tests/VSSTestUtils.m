//
//  VSSTestUtils.m
//  VirgilSDK
//
//  Created by Eugen Pivovarov on 1/29/18.
//  Copyright © 2018 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VSSTestUtils.h"

@implementation VSSTestUtils

- (instancetype __nonnull)initWithCrypto:(VSMVirgilCrypto *)crypto consts:(VSSTestsConst *)consts {
    self = [super init];
    if (self) {
        _consts = consts;
        _crypto = crypto;
    }
    return self;
}

- (VSSRawSignedModel *)instantiateRawSignedModelWithKeyPair:(VSMVirgilKeyPair *)keyPair identity:(NSString *)identity error:(NSError * __nullable * __nullable)errorPtr {
    
    VSMVirgilKeyPair *kp = keyPair != nil ? keyPair : [self.crypto generateKeyPairAndReturnError:errorPtr];
    NSString *idty = identity != nil ? identity : [[NSUUID alloc] init].UUIDString;
    
    NSData *exportedPublicKey = [_crypto exportVirgilPublicKey:kp.publicKey];
    NSString *publicKeyBase64 = [exportedPublicKey base64EncodedStringWithOptions:0];
    
    VSSRawCardContent *content = [[VSSRawCardContent alloc] initWithIdentity:idty publicKey:publicKeyBase64 previousCardId:nil version:nil createdAt:NSDate.date];
    
    NSData *snapshot = [content snapshot];
    
    VSSRawSignedModel *rawCard = [[VSSRawSignedModel alloc] initWithContentSnapshot:snapshot signatures:nil];
    
    VSMVirgilCardCrypto *cardCrypto = [[VSMVirgilCardCrypto alloc] init];
    VSSModelSigner *signer = [[VSSModelSigner alloc] initWithCrypto:cardCrypto];
    [signer selfSignWithModel:rawCard privateKey:keyPair.privateKey additionalData:nil error:errorPtr];

    return rawCard;
}

- (NSString * __nonnull)getTokenWithIdentity:(NSString * __nonnull)identity error:(NSError * __nullable * __nullable)errorPtr {
    VSMVirgilPrivateKeyExporter *exporter = [[VSMVirgilPrivateKeyExporter alloc] initWithVirgilCrypto:_crypto password:nil];
    
    NSData *privKey = [[NSData alloc] initWithBase64EncodedString:_consts.accessPrivateKeyBase64 options:0];
    
    VSMVirgilPrivateKey *privateKey = (VSMVirgilPrivateKey *)[exporter importPrivateKeyFrom:privKey error:errorPtr];
    
    VSMVirgilAccessTokenSigner *tokenSigner = [[VSMVirgilAccessTokenSigner alloc] init];
    VSSJwtGenerator *generator = [[VSSJwtGenerator alloc] initWithApiKey:privateKey apiPublicKeyIdentifier:_consts.accessPublicKeyId accessTokenSigner:tokenSigner appId:_consts.applicationId ttl:1000];
    
    VSSJwt *jwtToken = [generator generateTokenWithIdentity:identity additionalData:nil error:errorPtr];

    NSString *strToken = [jwtToken stringRepresentation];
    
    NSData *pubKey = [[NSData alloc] initWithBase64EncodedString:_consts.accessPublicKeyBase64 options:0];
    VSMVirgilPublicKey *key =  [_crypto importVirgilPublicKeyFrom:pubKey];
    
    VSSJwtVerifier *verifier = [[VSSJwtVerifier alloc] initWithApiPublicKey:key apiPublicKeyIdentifier:_consts.accessPublicKeyId accessTokenSigner:tokenSigner];
    
    [verifier verifyTokenWithJwtToken:jwtToken error:errorPtr];
    
    return strToken;
}

- (NSString * __nonnull)getTokenWithWrongPrivateKeyWithIdentity:(NSString * __nonnull)identity error:(NSError * __nullable * __nullable)errorPtr {
    VSMVirgilKeyPair *wrongKeyPair = [self.crypto generateKeyPairAndReturnError:errorPtr];
    VSMVirgilPrivateKey *privateKey = wrongKeyPair.privateKey;
    
    VSMVirgilAccessTokenSigner *tokenSigner = [[VSMVirgilAccessTokenSigner alloc] init];
    VSSJwtGenerator *generator = [[VSSJwtGenerator alloc] initWithApiKey:privateKey apiPublicKeyIdentifier:_consts.accessPublicKeyId accessTokenSigner:tokenSigner appId:_consts.applicationId ttl:1000];
    
    VSSJwt *jwtToken = [generator generateTokenWithIdentity:identity additionalData:nil error:errorPtr];
    
    NSString *strToken = [jwtToken stringRepresentation];
    
    return strToken;
}

-(BOOL)isCardsEqualWithCard:(VSSCard * __nonnull)card1 and:(VSSCard * __nonnull)card2 {
    return ([card1.identifier      isEqualToString: card2.identifier] &&
            [card1.identity        isEqualToString: card2.identity]   &&
            [card1.version         isEqualToString: card2.version]    &&
            card1.isOutdated       == card2.isOutdated                &&
            card1.createdAt        == card2.createdAt                 &&
            ([card1.previousCardId isEqualToString: card2.previousCardId]          || (card1.previousCardId == nil && card2.previousCardId == nil)) &&
            ([self isCardsEqualWithCard:card1.previousCard and:card2.previousCard] || (card1.previousCard   == nil && card2.previousCard   == nil)));
}

-(BOOL)isRawCardContentEqualWithContent:(VSSRawCardContent * __nonnull)content1 and:(VSSRawCardContent * __nonnull)content2 {
    return ([content1.identity       isEqualToString: content2.identity]        &&
            [content1.publicKey      isEqualToString: content2.publicKey]      &&
            [content1.version        isEqualToString: content2.version]        &&
            content1.createdAt       == content2.createdAt                     &&
            ([content1.previousCardId isEqualToString: content2.previousCardId] || (content1.previousCardId == nil && content2.previousCardId == nil)));
}

@end
